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
  description = "Project ID for the Record Manager deployment"
  type        = string
}

variable "non_production_project_id" {
  description = "Project ID for the non-production environment"
  type        = string
}

variable "region" {
  description = "Region for the Record Manager deployment"
  type        = string
  default     = "us-central1"
}

variable "data_domain_name" {
  description = "Domain name for the Data Platform being analyzed"
  type        = string
}

variable "environment" {
  description = "Environment to target for Record Manager deployment"
  type        = string
}

variable "record_manager_image_name" {
  description = "Record Manager image name"
  type        = string
}

variable "record_manager_image_tag" {
  description = "Record Manager image tag"
  type        = string
}

variable "artifact_project_id" {
  description = "Project ID for the Artifact Registry where images are stored"
  type        = string
}

variable "artifact_repository_name" {
  description = "Repository name of the Artifact Registry where images are stored"
  type        = string
}

variable "artifact_repository_folder" {
  description = "Repository folder of the Artifact Registry where images are stored"
  type        = string
}

variable "cloud_run_service_account" {
  description = "Cloud Run service account"
  type        = string
}

variable "record_manager_config_template_file" {
  description = "Path to the Record Manager config template file"
  type        = string
}

variable "remote_connection" {
  description = "Remote Connection name"
  type        = string
}

variable "tag_engine_endpoint" {
  description = "FQDN of the tag engine endpoint"
  type        = string
}

variable "record_manager_config_bucket" {
  description = "The name of the bucket containing the configuration files for the record manager"
  type        = string
}

variable "datasets_in_scope" {
  description = "List of datasets in scope"
  type        = list(string)
}
variable "record_manager_config" {
  description = "map of objects for the record manager configuration."
  type = object({
    template_id               = string
    retention_period_field    = string
    expiration_action_field   = string
    snapshot_dataset          = string
    snapshot_retention_period = number
    archives_bucket           = string
    export_format             = string
    archives_dataset          = string
    mode                      = string
  })
}

# variable "dlp_job_inspect_datasets" {
#   description = "The datasets to be inspected."
#   type = list(object({
#     environment               = string,
#     domain_name               = string,
#     business_code             = string,
#     inspection_dataset        = string,
#     resulting_dataset         = string,
#     inspecting_table_ids      = list(string)
#     inspect_config_info_types = list(string)
#     })
#   )
# }
