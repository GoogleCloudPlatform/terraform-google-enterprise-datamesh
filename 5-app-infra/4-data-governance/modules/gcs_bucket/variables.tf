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
  description = "project to add bucket to"
  type        = string
}

variable "bucket_name" {
  description = "The name of the GCS bucket."
  type        = string
}

variable "bucket_location" {
  description = "The location of the GCS bucket (e.g., US, EU)."
  type        = string
}

variable "storage_class" {
  description = "The storage class of the bucket (e.g., STANDARD, NEARLINE, COLDLINE, ARCHIVE)."
  type        = string
  default     = "STANDARD"
}

variable "uniform_bucket_level_access" {
  description = "Enables uniform bucket-level access when set to true."
  type        = bool
  default     = true
}

variable "force_destroy" {
  description = "When deleting, delete all objects in the bucket first."
  type        = bool
  default     = false
}

variable "enable_versioning" {
  description = "Enable versioning for the bucket."
  type        = bool
  default     = false
}

variable "default_kms_key_name" {
  description = "The default KMS key name for the bucket."
  type        = string
  default     = null
}
