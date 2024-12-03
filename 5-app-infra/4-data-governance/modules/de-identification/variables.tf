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

variable "dlp_location" {
  description = "The location of DLP resources. See https://cloud.google.com/dlp/docs/locations. The 'global' KMS location is valid."
  type        = string
  default     = "global"
}

variable "crypto_key_name" {
  description = "The name of the crypto key used to encrypt the wrapper."
  type        = string
}

variable "wrapped_key_secret_id" {
  description = "The secret id where the wrapped key is stored"
  type        = string
}


variable "template_id_prefix" {
  description = "Prefix to be used in the creation of the ID of the DLP de-identification template."
  type        = string
  default     = "de_identification"
}

variable "template_display_name" {
  description = "The display name of the DLP de-identification template."
  type        = string
  default     = "De-identification template using a KMS wrapped CMEK"
}

variable "template_description" {
  description = "A description for the DLP de-identification template."
  type        = string
  default     = "Transforms sensitive content defined in the template with a KMS wrapped CMEK."
}

variable "common_secrets_project_id" {
  description = "value of the project in which the shared secret resides."
  type        = string
}

variable "deidentify_field_transformations" {
  description = "List of field transformations for the de-identification template."
  type        = list(any)
}
