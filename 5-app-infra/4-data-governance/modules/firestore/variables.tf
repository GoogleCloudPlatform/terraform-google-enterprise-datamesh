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
  description = "The project ID where Firestore will be deployed"
  type        = string
}

variable "database_id" {
  description = "The Firestore database ID"
  type        = string
}

variable "location_id" {
  description = "The location ID where Firestore is deployed"
  type        = string
}

variable "firestore_type" {
  description = "The type of Firestore database"
  type        = string
}

variable "delete_protection_state" {
  description = "State of delete protection Enable or Disable"
  type        = string
  default     = "DELETE_PROTECTION_ENABLED"
}

variable "deletion_policy" {
  description = "Policy for deletion of the database"
  type        = string
  default     = "null"
}

variable "concurrency_mode" {
  description = "The concurrency mode for the Firestore database."
  type        = string
}

variable "point_in_time_recovery_enablement" {
  description = "Enable/Disable PIT recovery for the Firestore database."
  type        = string
  default     = "POINT_IN_TIME_RECOVERY_ENABLED"
}

variable "kms_key_name" {
  description = "The KMS key name for CMEK."
  type        = string
  default     = null
}

variable "firestore_index_config_file" {
  description = "The path to the Firestore index config file."
  type        = string
}
