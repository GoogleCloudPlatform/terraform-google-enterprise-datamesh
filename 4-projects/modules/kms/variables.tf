/**
 * Copyright 2021 Google LLC
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
  description = "The name of the key to be created"
  type        = string
}

variable "project_id" {
  description = "Needed to identify the project which kms viewer will be attached to"
  type        = string
  default     = null
}

variable "enable_cloudbuild_deploy" {
  description = "Enable infra deployment using Cloud Build"
  type        = bool
  default     = false
}

variable "key_rotation_period" {
  description = "Rotation period in seconds to be used for KMS Key"
  type        = string
  default     = "7776000s"
}

variable "key_ring" {
  description = "Keyring to attach project key to"
  type        = string
}

variable "app_infra_pipeline_service_account" {
  description = "The Service Accounts from App Infra Pipeline. Only needs input if enable_cloudbuild_deploy is true."
  type        = string
  default     = null
}

variable "additional_kms_viewer_members" {
  description = "Additional members to add to KMS Viewer role"
  type        = list(string)
  default     = []
}

variable "prevent_destroy" {
  description = "Set the prevent_destroy lifecycle attribute on keys."
  type        = bool
  default     = true
}

variable "encrypter_decrypters" {
  description = "List of accounts that can encrypt and decrypt the key created"
  type        = list(string)
  default     = []
}
