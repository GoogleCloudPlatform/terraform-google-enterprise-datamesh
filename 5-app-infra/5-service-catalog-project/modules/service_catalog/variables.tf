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
  description = "Service Catalog project ID."
  type        = string
}

variable "common_secrets_project_id" {
  description = "Common Secrets project ID."
  type        = string
}

variable "gh_token_secret" {
  description = "GitHub Token secret name."
  type        = string
}

variable "gh_app_installation_id" {
  description = "GitHub Application installation ID."
  type        = string
}

variable "bucket_name_prefix" {
  description = "Prefix of the bucket name"
  type        = string
  default     = "bkt"
}

variable "bucket_roles" {
  description = "Prefix of the bucket name"
  type        = map(any)
  default     = {}
}

variable "region" {
  type        = string
  description = "The region."
}

variable "service_catalog_kms_keys" {
  description = "Service Catalog KMS Keys."
  type        = map(any)
}

variable "project_service_account_email" {
  description = "Project service account email."
  type        = string
}

variable "solutions_repository" {
  description = "GitHub repository object for the Service Catalog solution."
  type        = any
}
