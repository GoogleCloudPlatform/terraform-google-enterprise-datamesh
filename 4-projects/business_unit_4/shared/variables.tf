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

variable "default_region" {
  description = "Default region to create resources where applicable."
  type        = string
  default     = "us-central1"
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

variable "remote_state_bucket" {
  description = "Backend bucket to load Terraform Remote State Data from previous steps."
  type        = string
}

#################################
# GitHub
#################################
variable "gh_common_project_repos" {
  description = "GitHub Common Project Repos"
  type = object({
    owner         = string
    project_repos = map(string)
  })
  default = null
}

variable "github_app_infra_token" {
  description = "value of github app infra token"
  type        = string
  sensitive   = true
}

variable "github_app_installation_id" {
  description = "Github App Installation ID"
  type        = number
}

variable "gh_artifact_repos" {
  description = "GitHub common Artifact Repo"
  type = object({
    owner                  = string
    artifact_project_repos = map(string)
  })
  default = null
}

variable "create_github_artifact_repositories" {
  description = "Create GitHub artifactrepositories"
  type        = bool
  default     = true
}

variable "key_rotation_period" {
  description = "Rotation period in seconds to be used for KMS Key"
  type        = string
  default     = "7776000s"
}

variable "create_repositories" {
  description = "create github repositories"
  type        = bool
}

variable "consumer_groups" {
  type = object({
    confidential_data_viewer                  = string
    non_confidential_data_viewer              = string
    non_confidential_encrypted_data_viewer    = string
    non_confidential_fine_grained_data_viewer = string
    non_confidential_masked_data_viewer       = string
  })
}
