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
  description = "Project ID"
  type        = string
}

variable "curl_timeout" {
  description = "Curl timeout in seconds"
  type        = number
  default     = 40
}

variable "environment" {
  description = "Target Environment"
  type        = string
}

variable "region" {
  description = "Region"
  type        = string
}

variable "cloud_run_sa" {
  description = "Cloud run service account"
  type        = string
}

variable "tag_engine_service_uri" {
  description = "Tag engine service uri"
  type        = string
}

variable "tag_engine_config_path" {
  description = "Path to the location of the tag engine congiguration template files"
  type        = string
}

variable "tag_engine_orchistration_path" {
  description = "Path to the location of the tag engine workflow template files"
  type        = string
}

variable "data_catalog_environment" {
  description = "data catalog envronment"
  type = map(object({
    secure_taxonomy = object({
      activated_policy_types = list(string)
      description            = string
      display_name           = string
      id                     = string
      name                   = string
      project                = string
      region                 = string
      timeouts               = optional(string, null)
    })
    sensitive_tag_ids = map(string)
  }))
}

variable "data_domain_projects" {
  description = "data domain projects"
  type = map(object({
    enabled_apis   = list(string)
    project_id     = string
    project_number = string
    sa             = string
  }))
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

variable "pricing_export_dataset_name" {
  description = "Pricing export dataset name"
  type        = string
  default     = "pricing_export"
}
