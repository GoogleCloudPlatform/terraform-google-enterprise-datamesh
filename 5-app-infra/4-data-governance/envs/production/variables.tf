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

variable "ddl_tables" {
  description = "The ddl tables to create"
  type        = map(list(string))
}

variable "environment" {
  description = "The environment."
  type        = string
}

variable "region" {
  description = "The region."
  type        = string
}

variable "business_unit" {
  description = "The business unit."
  type        = string
}

variable "remote_state_bucket" {
  description = "The name of the remote state bucket."
  type        = string
}

variable "tag_history_dataset_name" {
  description = "value of the tag history dataset name"
  type        = string
  default     = "tag_history_logs"
}

variable "dlp_job_inspect_datasets" {
  description = "The datasets to be inspected."
  type = list(object({
    environment   = string,
    domain_name   = string,
    business_code = string,
    owner_information = object({
      name               = string
      email              = string
      is_sensitive       = bool
      sensitive_category = string
      is_authoritative   = bool
    })
    inspection_dataset        = string,
    resulting_dataset         = string,
    inspecting_table_ids      = list(string)
    inspect_config_info_types = list(string)
    })
  )
}

variable "data_catalog_sensitive_tags" {
  description = "Data catalog tags marked for sensitive data."
  type = map(object({
    display_name   = string
    description    = optional(string)
    masking_policy = string
  }))
}

variable "tag_history_dataset_id" {
  type        = string
  description = "Tag history dataset id"
  default     = "tag_history_logs"
}

variable "data_quality_image_name" {
  type        = string
  description = "Data quality image name used for cloud run"
  default     = "cdmc_data_quality"
}

variable "data_quality_image_tag" {
  description = "value of the data quality image tag"
  type        = string
  default     = "latest"
}

variable "report_engine_image_name" {
  type        = string
  description = "Report engine image name used for cloud run"
  default     = "report_engine"
}

variable "report_engine_image_tag" {
  description = "value of the report engine image tag"
  type        = string
  default     = "latest"
}

variable "tag_engine_api_image_name" {
  type        = string
  description = "Tag engine api image name used for cloud run"
  default     = "tag_engine_api"
}

variable "tag_engine_image_tag" {
  description = "value of the tag engine image tag"
  type        = string
  default     = "latest"
}

variable "data_access_management_image_name" {
  description = "value of the data access management api image name"
  type        = string
  default     = "data_access_management_api"
}

variable "data_access_management_image_tag" {
  description = "value of the data access management api image tag"
  type        = string
  default     = "latest"
}

variable "artifact_repository_name" {
  description = "Artifact repository name used for cloud run"
  type        = string
  default     = "cdmc"
}

variable "artifact_repository_folder" {
  description = "Artifact repository folder used for cloud run"
  type        = string
  default     = "cdmc"
}

variable "firestore_database_id" {
  description = "Firestore database id"
  type        = string
  default     = "firestore-tag-engine"
}

variable "tag_engine_injector_queue_name" {
  description = "Tag engine injector queue name"
  type        = string
  default     = "tag-engine-injector-queue"
}

variable "tag_engine_work_queue_name" {
  description = "Tag engine work queue name"
  type        = string
  default     = "tag-engine-work-queue"
}

## Record Manager CloudRun
variable "record_manager_image_name" {
  description = "Data quality image name used for cloud run"
  default     = "record_manager"
  type        = string
}

variable "record_manager_image_tag" {
  description = "Record Manager image tag"
  type        = string
  default     = "latest"
}

variable "pricing_export_dataset_name" {
  description = "Pricing export dataset name"
  type        = string
  default     = "pricing_export"
}

## GCS Bucket
variable "record_manager_bucket_name" {
  description = "The name of the GCS bucket."
  type        = string
  default     = "record_manager_configs"
}


variable "bucket_storage_class" {
  description = "The storage class of the bucket"
  type        = string
  default     = "STANDARD"
}


# Template file variables
variable "record_manager_config" {
  description = "map of objects for the data retention configuration."
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

variable "deidentify_field_transformations" {
  description = "List of field transformations for the de-identification template."
  type        = list(any)
}



