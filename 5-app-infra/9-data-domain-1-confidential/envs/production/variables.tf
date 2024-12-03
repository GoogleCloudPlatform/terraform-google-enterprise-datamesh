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

variable "env" {
  description = "Environment"
  type        = string
}

variable "region" {
  description = "Region"
  type        = string
}

variable "bigquery_dataset_id_prefix" {
  description = "Dataset ID prefix"
  type        = string
}

variable "bigquery_non_confidential_dataset_id_prefix" {
  description = "Dataset ID prefix of Non Confidential Datasets in Non Confidential Data Domain Project"
  type        = string
}

variable "remote_state_bucket" {
  description = "Name of the remote state bucket"
  type        = string
}

variable "data_governance_state_bucket" {
  type        = string
  description = "Name of the data governance state bucket"
}

variable "domain_name" {
  description = "Domain name"
  type        = string
}

variable "business_unit" {
  description = "Business unit"
  type        = string
}

variable "business_code" {
  description = "Business code"
  type        = string
}

variable "dataflow_template_jobs" {
  description = "Dataflow template jobs"
  type = map(object({
    image_name            = string
    template_filename     = string
    additional_parameters = optional(map(string))
    csv_file_names        = optional(list(string))
  }))
}

variable "dataflow_gcs_bucket_url" {
  description = "The dataflow gcs template bucket url"
  type        = string
}

variable "dataflow_repository_name" {
  description = "The docker repository name created in artifacts project"
  type        = string
}

variable "env_code" {
  description = "Environment code for this environment"
  type        = string
}

variable "confidential_datasets" {
  description = "Confidential datasets and table schemas"
  type = list(object({
    name          = string
    tables_schema = map(string)
  }))
}

variable "keyring_name" {
  description = "Keyring name"
  type        = string
}