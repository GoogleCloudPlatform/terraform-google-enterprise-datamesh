/**
* Copyright 2024 Google LLC
*
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
*      http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/

variable "project_id" {
  description = "The project ID to deploy to"
  type        = string
}

variable "region" {
  description = "The Cloud Function region"
  type        = string
  default     = "northamerica-northeast1"
}

// Cloud Function Source Bucket 
variable "bucket_name" {
  description = "The GCS bucket name to store the cloud function code"
  type        = string
}

// Cloud Function Source ZIP
variable "source_path" {
  description = "The local path to the function code ZIP file"
  type        = string
}

variable "source_archive_object" {
  description = "The function code ZIP file object name in the Bucket"
  type        = string
  default     = "function-code.zip"
}

// Cloud Function
variable "function_name" {
  description = "Cloud Function name"
  type        = string
}

variable "function_description" {
  description = "Cloud Function Description"
  type        = string
}

variable "runtime" {
  description = "The Cloud Function runtime"
  type        = string
  default     = "python311"
}

variable "function_memory" {
  description = "The Memory allocated for the Cloud Function, define in MB"
  type        = string
  default     = "256Mi"
}

variable "entry_point" {
  description = "Cloud Function entry point"
  type        = string
  default     = "event_handler"
}

variable "environment_variables" {
  description = "Function Environment variables"
  type        = map(string)
  default = {
    ENV_VAR = "value"
  }
}

variable "service_account_email" {
  description = "The service account to run the cloud function."
  type        = string
  default     = null
}

variable "build_service_account_email" {
  description = "The service account to use for Cloud Build when deploying the cloud function."
  type        = string
  default     = null
}

variable "kms_key_name" {
  description = "The KMS key to encrypt environment variables at rest."
  type        = string
  default     = null
}

variable "ingress_settings" {
  description = "The ingress settings for the cloud function."
  type        = string
  default     = "ALLOW_ALL"
}

// Cloud Function Invoker IAM Member 
variable "invoker_member" {
  description = "Grant the Invoker IAM role/access to a user, group or service account"
  type        = string
}

// BigQuery Job Remote Function 
variable "template_path" {
  type        = string
  description = "Path to the SQL template files each Cloud Function"
  default     = ""
}

variable "remote_connection_name" {
  description = "Defines the bq connection API"
  type        = string
  default     = ""
}

variable "dataset" {
  description = "The bq dataset"
  type        = string
  default     = ""
}

variable "domain_name" {
  description = "The data domain name"
  type        = string
  default     = ""
}

variable "create_bigquery_remote_function" {
  description = "Create BigQuery Remote Function"
  type        = bool
  default     = true
}
