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
  description = "The ID of the project in which to provision resources."
  type        = string
}

variable "data_project_id" {
  description = "The ID of the project in which the inspection data resides"
  type        = string
}

variable "dlp_location" {
  description = "The location of DLP resources. See https://cloud.google.com/dlp/docs/locations. The 'global' KMS location is valid."
  type        = string
  default     = "global"
}

variable "dlp_job_description" {
  description = "The description of the DLP job trigger."
  type        = string
  default     = "CDMC inspection job"
}

variable "dlp_job_trigger_id" {
  description = "The ID of the DLP job trigger."
  type        = string
  default     = null
}

variable "dlp_job_recurrence_period_duration" {
  description = "The duration of the DLP job trigger."
  type        = string
}

variable "dlp_job_status" {
  description = "The status of the DLP job trigger."
  type        = string
  default     = "HEALTHY"

  validation {
    condition     = contains(["HEALTHY", "PAUSED", "CANCELLED"], var.dlp_job_status)
    error_message = "The status must be one of: HEALTHY, PAUSED, CANCELLED."
  }
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

