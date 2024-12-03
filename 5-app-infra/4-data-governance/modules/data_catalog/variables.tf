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


variable "sensitive_tags" {
  description = "object of sensitive tags"
  type = map(object({
    display_name   = string
    description    = optional(string)
    masking_policy = string
  }))
}

variable "location" {
  description = "value of location"
  type        = string
}

variable "taxonomy_display_name" {
  description = "Display name for taxonomy"
  type        = string
  default     = "sensitive_data_classification"
}

variable "project_id" {
  description = "Data governance project_id"
  type        = string
}

variable "masked_dataflow_controller_members" {
  description = "memebrs allowed to access masked data"
  type        = list(string)
}

variable "fine_grained_access_control_members" {
  description = "fine grained access control members"
  type        = list(string)
}

variable "datacatalog_viewer_members" {
  description = "datacatalog viewer members"
  type        = list(string)
}

variable "data_domain_name" {
  type        = string
  description = "The name of the domain."
}

variable "environment" {
  type        = string
  description = "Environment"
}

variable "datacatalog_templates" {
  description = "List of yaml files for creating templates."
  type        = list(string)
  default     = []
}
