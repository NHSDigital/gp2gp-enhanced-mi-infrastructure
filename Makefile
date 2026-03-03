BUILD_PATH = stacks/degrades-reporting/terraform/lambda/build
DEGRADES_LAMBDA_PATH = lambda/degrades-reporting
LAMBDA_TEST_PATH = lambdas/tests
UTILS = degrade_utils
REQUIREMENTS_PATH=lambdas/requirements
SHARED_REQUIREMENTS=$(REQUIREMENTS_PATH)/shared_requirements.txt
TEST_REQUIREMENTS=$(REQUIREMENTS_PATH)/test_requirements.txt

env:
	@echo "Removing old venv."
	@rm -rf lambdas/venv || true
	@echo "Building new venv and installing requirements."
	@python3.13 -m venv ./lambdas/venv
	@./lambdas/venv/bin/pip3 install --upgrade pip
	@./lambdas/venv/bin/pip3 install -r $(SHARED_REQUIREMENTS) --no-cache-dir
	@./lambdas/venv/bin/pip3 install -r $(TEST_REQUIREMENTS) --no-cache-dir
	./lambdas/venv/bin/pip install pytest pytest-cov pytest-mock
	@echo "Now activate your venv."

degrades-env:
	cd $(DEGRADES_LAMBDA_PATH) && rm -rf venv || true
	cd $(DEGRADES_LAMBDA_PATH) && python3.12 -m venv ./venv
	cd $(DEGRADES_LAMBDA_PATH) && ./venv/bin/pip3 install --upgrade pip
	cd $(DEGRADES_LAMBDA_PATH) && ./venv/bin/pip3 install -r requirements.txt --no-cache-dir


test-degrades:
	rm -rf tmp/reports || true
	mkdir -p tmp/reports
	cd $(DEGRADES_LAMBDA_PATH)  && venv/bin/python3 -m pytest tests/

setup-test-env:
	rm -rf tmp/reports || true
	mkdir -p tmp/reports
	rm -rf $(LAMBDA_TEST_PATH)/.venv
	python 3.12 -m venv $(LAMBDA_TEST_PATH)/.venv
	$(LAMBDA_TEST_PATH)/.venv/bin/pip install -r lambdas/test_requirements.txt pytest pytest-cov

#test-lambdas-with-coverage:
#	cd ./lambdas && ./.venv/bin/python3 -m pytest \
#    --cov=. \
#    --cov-report=xml:../../tmp/reports/coverage.xml

test-lambdas-with-coverage:
	cd ./lambdas && PYTHONPATH=.:./tests ./venv/bin/python3 -m pytest tests \
		-vv \
		--cov=. \
		--cov-report=xml:../tmp/reports/coverage.xml

test-degrades-coverage:
	rm -rf tmp/reports || true
	mkdir -p tmp/reports
	cd $(DEGRADES_LAMBDA_PATH) && ./venv/bin/coverage run -m pytest tests/
	cd $(DEGRADES_LAMBDA_PATH) && ./venv/bin/coverage report -m


zip-lambda-layer:
	cd $(DEGRADES_LAMBDA_PATH) && rm -rf ../../$(BUILD_PATH) || true
	cd $(DEGRADES_LAMBDA_PATH) && mkdir -p ../../$(BUILD_PATH)/layers
	cd $(DEGRADES_LAMBDA_PATH) && ./venv/bin/pip3 install \
		--platform manylinux2014_x86_64 --only-binary=:all: --implementation cp --python-version 3.12 -r layers/requirements_core.txt -t ../../$(BUILD_PATH)/layers/core/python/lib/python3.12/site-packages
	cd $(BUILD_PATH)/layers/core && zip -r -X ../../degrades-lambda-layer.zip .

	cd $(DEGRADES_LAMBDA_PATH) && ./venv/bin/pip3 install \
		--platform manylinux2014_x86_64 --only-binary=:all: --implementation cp --python-version 3.12 -r layers/requirements_pandas.txt -t ../../$(BUILD_PATH)/layers/pandas/python/lib/python3.12/site-packages
	cd $(BUILD_PATH)/layers/pandas && zip -r -X ../../pandas-lambda-layer.zip .


zip-degrades-lambdas: zip-lambda-layer
	cd $(DEGRADES_LAMBDA_PATH) && rm -rf ../../$(BUILD_PATH)/degrades-message-receiver || true
	cd $(DEGRADES_LAMBDA_PATH) && rm -rf ../../$(BUILD_PATH)/degrades-daily-summary || true

	cd $(DEGRADES_LAMBDA_PATH) && mkdir -p ../../$(BUILD_PATH)/degrades-message-receiver
	cd $(DEGRADES_LAMBDA_PATH) && mkdir -p ../../$(BUILD_PATH)/degrades-daily-summary

	cp ./$(DEGRADES_LAMBDA_PATH)/degrades_message_receiver/main.py $(BUILD_PATH)/degrades-message-receiver
	cp ./$(DEGRADES_LAMBDA_PATH)/degrades_daily_summary/main.py $(BUILD_PATH)/degrades-daily-summary

	cp -r $(DEGRADES_LAMBDA_PATH)/$(UTILS) $(BUILD_PATH)/degrades-message-receiver/$(UTILS)
	cp -r $(DEGRADES_LAMBDA_PATH)/$(UTILS) $(BUILD_PATH)/degrades-daily-summary/$(UTILS)


	cp -r $(DEGRADES_LAMBDA_PATH)/models $(BUILD_PATH)/degrades-message-receiver/models
	cp -r $(DEGRADES_LAMBDA_PATH)/models $(BUILD_PATH)/degrades-daily-summary/models


	cd $(BUILD_PATH)/degrades-message-receiver && zip -r -X ../degrades-message-receiver.zip .
	cd $(BUILD_PATH)/degrades-daily-summary && zip -r -X ../degrades-daily-summary.zip .


format-degrades:
	cd $(DEGRADES_LAMBDA_PATH) && ./venv/bin/ruff format
	cd stacks/degrades-reporting/terraform && terraform fmt -recursive


