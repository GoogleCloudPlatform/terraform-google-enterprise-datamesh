/**
 * Copyright 2023 Google LLC
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

variable "gcs_bucket_prefix" {
  description = "Name prefix to be used for GCS Bucket"
  type        = string
  default     = "bkt"
}

variable "data_domain" {
  description = "values for data domains"
  type = object(
    {
      name                 = string
      ingestion_apis       = optional(list(string), [])
      nonconfidential_apis = optional(list(string), [])
      confidential_apis    = optional(list(string), [])
    }
  )

  validation {
    condition     = var.data_domain.name == regex("[^ ]+", var.data_domain.name)
    error_message = "The 'name' attribute in 'data_domain' must not contain spaces."
  }
}

variable "ingestion_bucket_location" {
  description = "Location of the ingestion bucket. Uses same kms key location"
  type        = string
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

variable "enable_bigquery_read_roles" {
  description = "Toggle creation of BigQuery read roles"
  type        = bool
  default     = false
}

variable "folder_name" {
  description = "Data domain filder name"
  type        = string
}

variable "remote_state_bucket" {
  description = "Backend bucket to load Terraform Remote State Data from previous steps."
  type        = string
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

variable "non_confidential_consumers_viewers_group_email" {
  description = "Consumers for the non-confidential proeject"
  type        = string
}

variable "non_confidential_fine_grained_data_viewer" {
  description = "Fine grained data viewers for the non-confidential proeject"
  type        = string
}

variable "non_confidential_encrypted_data_viewer" {
  description = "Encrypted data viewers for the non-confidential proeject"
  type        = string
}

variable "non_confidential_masked_data_viewer" {
  description = "Masked data viewers for the non-confidential proeject"
  type        = string
}

variable "confidential_consumers_viewers_group_email" {
  description = "Consumers group for the confidential proeject"
  type        = string
}

variable "create_resource_locations_policy" {
  description = <<EOT
    Whether to create the Organization policy to limit resource location for confidential and non-confidential projects
    Required for the Tag engine. However, if the policy is created on the initial Terraform apply, the validation (gcloud terraform vet)
    fails with error: Error converting TF resource to CAI: Invalid parent address() for an asset.
    So the idea is to skip the policy creation on the initial Terraform apply, then enable it once the projects are created.
    EOT
  type        = bool
  default     = true
}
