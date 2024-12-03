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

variable "name" {
  description = " Name of the Job"
  type        = string
}

variable "location" {
  description = "The location of the cloud run job"
  type        = string
}

variable "project_id" {
  description = "project id of the cloud run job"
  type        = string
}

variable "image_name" {
  type        = string
  description = "image name to run the cloud job"
}

variable "image_region" {
  type        = string
  description = "image region to run the cloud job"
  default     = "us-central1"
}

variable "image_tag" {
  type        = string
  description = "image tag to run the cloud job"
  default     = "latest"
}

variable "artifact_project_id" {
  type        = string
  description = "project id of the artifact registry where the image resides"
}

variable "artifact_repository_name" {
  type        = string
  description = "repository name of the artifact registry where the image resides"
  default     = "cdmc"
}

variable "artifact_repository_folder" {
  type        = string
  description = "value of the folder in the artifact registry where the image resides"
  default     = null
}

variable "args" {
  type        = list(string)
  description = "Arguments to the entrypoint"
  default     = []
}

variable "environment_variables" {
  type    = map(string)
  default = null
}

variable "timeout_seconds" {
  type        = number
  description = "Timeout in seconds"
  default     = 3600
}

variable "cloud_run_service_account" {
  type        = string
  description = "The service account used for executing the job."
}

variable "encryption_key" {
  type        = string
  default     = null
  description = "A reference to a customer managed encryption key (CMEK) to use to encrypt this container image."
}

variable "cloud_run_type" {
  type        = string
  default     = "RUN"
  description = "The type of cloud run job"

  validation {
    condition     = var.cloud_run_type == "RUN" || var.cloud_run_type == "SERVICE"
    error_message = "value must be either 'RUN' or 'SERVICE'"
  }
}

variable "cpu_limit" {
  type        = string
  description = "CPU Limit value"
  default     = "1"

  validation {
    condition     = var.cpu_limit == "1" || var.cpu_limit == "2" || var.cpu_limit == "4" || var.cpu_limit == "8"
    error_message = "value must be either '1', '2', '4' or '8'"
  }
}

variable "memory_limit" {
  type        = string
  description = "Memory Limit value"
  default     = "512Mi"
}
