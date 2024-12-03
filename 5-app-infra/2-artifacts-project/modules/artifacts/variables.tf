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


variable "artifacts_repository_cleanup_policies" {
  description = "List of cleanup policies."
  type = list(object({
    id     = string
    action = optional(string)
    condition = optional(list(object({
      tag_state             = optional(string)
      tag_prefixes          = optional(list(string))
      package_name_prefixes = optional(list(string))
      older_than            = optional(string)
    })))
    most_recent_versions = optional(list(object({
      package_name_prefixes = optional(list(string))
      keep_count            = optional(number)
    })))
  }))
  default = null
}

variable "default_region" {
  description = "Default region to create resources where applicable."
  type        = string
  default     = "us-central1"
}

variable "project_id" {
  description = "Project ID of for the artifacts"
  type        = string
}

variable "remote_state_bucket" {
  description = "Backend bucket to load Terraform Remote State Data from previous steps."
  type        = string
}

variable "bucket_name_prefix" {
  description = "Prefix of the bucket name"
  type        = string
  default     = "bkt"
}

variable "github_app_installation_id" {
  description = "Github App Installation ID"
  type        = number
}

variable "business_unit" {
  description = "value of business unit"
  type        = string
}


