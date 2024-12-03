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

variable "remote_state_bucket" {
  type        = string
  description = "Name of the remote state bucket"
}

variable "data_governance_state_bucket" {
  type        = string
  description = "Name of the data governance state bucket"
}
variable "business_unit" {
  type        = string
  description = "Business unit"
}

variable "business_code" {
  type        = string
  description = "Business code"
}
variable "domain_name" {
  type        = string
  description = "value of Data domain name"
}

variable "env" {
  type        = string
  description = "Environment"
}

variable "env_code" {
  description = "Environment code"
  type        = string
}


variable "region" {
  type        = string
  description = "Region"
}

variable "pubsub_topic_labels_additional" {
  type        = map(string)
  description = "Additional topic labels"
  default     = {}
}

variable "pubsub_message_storage_policy_regions_additional" {
  type        = list(string)
  description = "Additional message storage policy regions"
  default     = []
}

variable "dataflow_gcs_bucket_url" {
  description = "The dataflow gcs template bucket url"
  type        = string
}

variable "dataflow_repository_name" {
  type        = string
  description = "The docker repository name created in artifacts project"
}

variable "dataflow_template_jobs" {
  type = map(object({
    image_name            = string
    template_filename     = string
    additional_parameters = optional(map(string))
    csv_file_names        = optional(list(string))
  }))
  description = "List of dataflow template jobs with i"
}

variable "non_confidential_datasets" {
  description = "List of non-confidential datasets"
  type = list(object({
    name              = string
    gcs_input_off     = optional(bool, false)
    pubsub_off        = optional(bool, false)
    tables_schema     = map(string)
    tables_file_names = optional(map(string))
  }))
}
