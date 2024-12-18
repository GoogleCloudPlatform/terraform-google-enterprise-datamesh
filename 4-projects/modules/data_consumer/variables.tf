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

variable "business_code" {
  description = "The business code (ex. bu1)."
  type        = string
}

variable "business_unit" {
  description = "The business (ex. business_unit_1)."
  type        = string
}

variable "env" {
  description = "The environment to prepare (ex. development)."
  type        = string
}

variable "folder_name" {
  description = "Data domain filder name"
  type        = string
}

variable "consumers_project" {
  description = "values for consumers projects"
  type = object(
    {
      name = string
      apis = optional(list(string), [])
    }
  )
}

variable "project_budget" {
  description = <<EOT
  Budget configuration.
  budget_amount: The amount to use as the budget.
  alert_spent_percents: A list of percentages of the budget to alert on when threshold is exceeded.
  alert_pubsub_topic: The name of the Cloud Pub/Sub topic where budget related messages will be published, in the form of `projects/{project_id}/topics/{topic_id}`.
  alert_spend_basis: The type of basis used to determine if spend has passed the threshold. Possible choices are `CURRENT_SPEND` or `FORECASTED_SPEND` (default).
  EOT
  type = object({
    budget_amount        = optional(number, 1000)
    alert_spent_percents = optional(list(number), [1.2])
    alert_pubsub_topic   = optional(string, null)
    alert_spend_basis    = optional(string, "FORECASTED_SPEND")
  })
  default = {}
}

variable "key_rings" {
  description = "Keyrings to attach project key to"
  type        = list(string)
}

variable "key_rotation_period" {
  description = "Rotation period in seconds to be used for KMS Key"
  type        = string
  default     = "7776000s"
}

variable "kms_key_prevent_destroy" {
  description = "KMS key prevent destroy"
  type        = bool
  default     = true
}

variable "remote_state_bucket" {
  description = "Backend bucket to load Terraform Remote State Data from previous steps."
  type        = string
}
