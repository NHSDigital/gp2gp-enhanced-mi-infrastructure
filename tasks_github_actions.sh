#!/bin/bash

set -Eeo pipefail

task="$1"

function build_lambda {
    lambda_name=$1
    source_path=$2
    lambda_services=$3

    build_dir=lambdas/build/$lambda_name
    shared_requirements=lambdas/requirements/shared_requirements.txt
    build_dir=lambdas/build/$lambda_name
    rm -rf $build_dir
    mkdir -p $build_dir

    cp -r "$source_path/$lambda_name/." "$build_dir/"

    if [ -n "$lambda_services" ]; then
      for folder in $lambda_services; do
        if [ -d "$source_path/$folder" ]; then
          cp -r "$source_path/$folder" "$build_dir"

          elif [ -d "$folder" ]; then
            cp -r "$folder" "build_dir"

          else
            echo "Cannot find '$folder'"
        fi
      done
    fi

    if [ -f "$shared_requirements" ]; then
      pip install -r "$shared_requirements" -t "$build_dir"
    fi

    pushd "$build_dir"
    zip -r -X "../$lambda_name.zip"
    popd
}

function build_lambda_layer {
    layer_name=$1
    build_dir="lambdas/build/layers/$layer_name"

    rm -rf "$build_dir"
    mkdir -p "$build_dir/python"

    requirements_file="lambdas/requirements/$layer_name-requirements.txt"

    if [ ! -f "$requirements_file" ]; then
        requirements_file="lambdas/requirements/requirements_$layer_name.txt"
    fi
    if [ -f "$requirements_file" ]; then
        python3 -m venv create_layer
        source create_layer/bin/activate

        pip install -q \
            --platform manylinux2014_x86_64 \
            --only-binary=:all: \
            --implementation cp \
            --python-version 3.12 \
            -r "$requirements_file"
        cp -r create_layer/lib/python3.12/site-packages/. "$build_dir/python/"

        deactivate
        rm -rf create_layer
    else
        echo "No requirements file found for $layer_name"
    fi

    pushd "$build_dir"
    zip -q -r -X "../$layer_name.zip" .
    popd
}

echo "--- ${task} ---"
case "${task}" in
build-lambdas)
  build_lambda_layer mi_enrichment
  build_lambda "bulk_ods_update" "lambdas" "utils"
  build_lambda "error_alarm_alert" "lambdas"
  build_lambda "splunk_cloud_event_uploader" "lambdas"
  build_lambda "event_enrichment" "lambdas" "utils"
  build_lambda "s3_event_uploader" "lambdas"
  build_lambda_layer pandas
  build_lambda_layer core
  build_lambda "degrades_daily_summary" "lambdas/degrades_reporting" "degrade_utils models"
  build_lambda "degrades_message_receiver" "lambdas/degrades_reporting" "degrade_utils models"

;;
*)
  echo "Invalid task: '${task}'"
  exit 1
  ;;
esac

set +e
