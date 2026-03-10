variable "environment" {
  type        = string
  description = "Uniquely identities each deployment, i.e. dev, prod."
}

variable "team" {
  type        = string
  default     = "Registrations"
  description = "Team owning this resource"
}

variable "repo_name" {
  type        = string
  default     = "gp2gp-enhanced-mi-infrastructure"
  description = "Name of this repository"
}

variable "gp_registrations_mi_repo_param_name" {
  type        = string
  description = "Docker repository of the gp registrations MI API"
}

variable "execution_role_arn_param_name" {
  type        = string
  description = "SSM parameter containing ecs execution role arn"
}

variable "gp_registrations_mi_image_tag" {
  type        = string
  description = "Docker image tag of the gp registrations MI API"
}

variable "log_group_param_name" {
  type        = string
  description = "Cloudwatch log group for gp registrations MI API"
}

variable "private_subnet_ids_param_name" {
  type        = string
  description = "List of private subnet IDs"
}

variable "vpc_id_param_name" {
  type        = string
  description = "VPC ID"
}

variable "vpc_cidr_block_param_name" {
  type        = string
  description = "VPC CIDR block"
}

variable "ecs_cluster_arn_param_name" {
  type        = string
  description = "ECS cluster arn"
}

variable "apigee_ips_param_name" {
  type        = string
  description = "Apigee IPs"
}

variable "retention_period_in_days" {
  type        = number
  default     = 120
  description = "The number of days for cloudwatch logs retention period"
}

locals {
  api_stage_name = "${var.environment}-env"
}

variable "enriched_mi_events_sns_topic_name" {
  default = "gp-registrations-mi-enriched-mi-events-sns-topic"
}

variable "splunk_cloud_url_param_name" {
  type        = string
  description = "SSM param containing splunk cloud url to send MI events to"
}

variable "splunk_cloud_api_token_param_name" {
  type        = string
  description = "SSM param containing splunk cloud api token to send MI events to"
}

variable "mi_enrichment_lambda_layer_zip" {
  type        = string
  description = "Path to zipfile containing relevant packages for MI lambdas"
  default     = "../../../lambdas/build/layers/mi_enrichment.zip"
}

variable "splunk_cloud_event_uploader_lambda_zip" {
  type        = string
  description = "Path to zipfile containing lambda code for uploading events to splunk cloud"
  default     = "../../../lambdas/build/splunk_cloud_event_uploader.zip"
}

variable "event_enrichment_lambda_zip" {
  type        = string
  description = "Path to zipfile containing lambda code for enriching MI events"
  default     = "../../../lambdas/build/event_enrichment.zip"
}

variable "bulk_ods_update_lambda_zip" {
  type        = string
  description = "Path to zipfile containing lambda code for ODS update"
  default     = "../../../lambdas/build/bulk_ods_update.zip"
}

variable "s3_event_uploader_lambda_zip" {
  type        = string
  description = "Path to zipfile containing lambda code for uploading to s3 bucket"
  default     = "../../../lambdas/build/s3_event_uploader.zip"
}

variable "error_alarm_alert_lambda_zip" {
  type        = string
  description = "Path to zipfile containing lambda code for sending alerts to"
  default     = "../../../lambdas/build/error_alarm_alert.zip"
}

variable "log_alerts_general_webhook_url_param_name" {
  type        = string
  description = "SSM parameter containing the general webhook url channel to send failure threshold succeeded notifications to"
}

#variable "cloudwatch_alarm_url" {
#  type        = string
#  description = "SSM parameter containing the cloudwatch alarm url (without region prepended)"
#}

variable "sds_fhir_api_key_param_name" {
  type        = string
  description = "SSM param containing SDS FHIR API token to retrieve supplier details"
}

variable "sds_fhir_api_url_param_name" {
  type        = string
  description = "SSM param containing SDS FHIR API url to retrieve supplier details"
}

variable "ods_bulk_update_lambda_name" {
  default     = "ods-bulk-update-lambda"
  type        = string
  description = "Name of the ODS bulk upload lambda"
}

variable "degrades_message_queue" {
  type        = string
  description = "Name of Degrades Message SQS queue"
}