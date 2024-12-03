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

###################################
# KMS
###################################
variable "keyring_name" {
  description = "Name of the keyring"
  type        = string
  default     = "sample-keyring"
}

variable "keyring_regions" {
  description = "Regions to create keyrings in"
  type        = list(string)
  default = [
    "us-central1",
    "us-east4"
  ]
}

variable "key_rotation_period" {
  description = "Key Rotation Period"
  type        = string
  default     = "7776000s"
}

###################################
# Secrets
###################################
variable "github_app_infra_token_secret_id" {
  description = "ID of the Secret in Secret Manager for the Github App Infra Token"
  type        = string
  default     = "github-app-infra-token"
}

variable "github_app_infra_token" {
  description = "Github App Infra Token"
  type        = string
}

variable "kms_wrapper_secret_id" {
  description = "ID of the Secret in Secret Manager for the KMS Wrapper Secret"
  type        = string
  default     = "kms-wrapper"
}

variable "tag_engine_oauth_client_id_secret_id" {
  description = "ID of the Secret in Secret Manager for the Tag Engine OAuth Client ID Secret"
  type        = string
  default     = "tag-engine-oauth-client-id"
}
