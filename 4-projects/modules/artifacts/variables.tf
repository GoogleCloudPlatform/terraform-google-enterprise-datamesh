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

variable "org_id" {
  description = "The organization id for the associated services"
  type        = string
}

variable "folder_id" {
  description = "The folder id where project will be created"
  type        = string
}

variable "billing_account" {
  description = "The ID of the billing account to associated this project with"
  type        = string
}

variable "project_suffix" {
  description = "Project suffix."
  type        = string
  default     = "artifacts"
}

variable "application_name" {
  description = "Application name."
  type        = string
  default     = "app-infra-artifacts"
}

variable "billing_code" {
  description = "Billing code."
  type        = string
  default     = "1234"
}

variable "primary_contact" {
  description = "Primary contact."
  type        = string
  default     = "example@example.com"
}

variable "secondary_contact" {
  description = "Secondary contact."
  type        = string
  default     = "example2@example.com"
}

variable "business_code" {
  description = "Business code"
  type        = string
  default     = "bu4"
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

variable "project_prefix" {
  description = "Name prefix to use for projects created."
  type        = string
  default     = "prj"
}

variable "shared_kms_key_ring" {
  description = "Shared KMS Key ring."
  type        = list(string)
}

variable "kms_key_prevent_destroy" {
  description = "KMS key prevent destroy"
  type        = bool
  default     = true
}

variable "app_infra_pipeline_service_accounts" {
  description = "App Infra Pipeline Terraform SA mapped to source repos as keys"
  type        = map(any)
}

variable "secrets_project_id" {
  description = "The common secrets project ID"
  type        = string
}

variable "key_rotation_period" {
  description = "Rotation period in seconds to be used for KMS Key"
  type        = string
  default     = "7776000s"
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

variable "gh_token_secret" {
  description = "GitHub Token Secret."
  type        = string
}

variable "tag_engine_oauth_secret" {
  description = "Tag Engine OAuth Secret."
  type        = string
}

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
