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

variable "shared_vpc_host_project_id" {
  description = "Shared VPC host project ID"
  type        = string
  default     = ""
}

variable "shared_vpc_subnets" {
  description = "List of the shared vpc subnets self links."
  type        = list(string)
  default     = []
}

variable "perimeter_name" {
  description = "Access context manager service perimeter name"
  type        = string
}

variable "access_context_manager_policy_id" {
  description = "Access Context Manager Policy ID."
  type        = string
}

variable "secrets_project_id" {
  description = "The common secrets project ID"
  type        = string
}

variable "kms_project_id" {
  description = "The common kms project ID"
  type        = string
}

variable "dlp_kms_wrapper_secret" {
  description = "The DLP KMS wrapper secret ID"
  type        = string
}

variable "key_rotation_period" {
  description = "Rotation period in seconds to be used for KMS Key"
  type        = string
  default     = "7776000s"
}

variable "project_suffix" {
  description = "Project suffix."
  type        = string
  default     = "data-governance"
}

variable "application_name" {
  description = "Application name."
  type        = string
  default     = "app-infra-data-governance"
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

variable "cloud_run_service_acount_id" {
  description = "Cloud Run service account ID"
  type        = string
  default     = "cloud-run"
}

variable "cloud_function_service_acount_id" {
  description = "Cloud Function service account ID"
  type        = string
  default     = "cloud-function"
}

variable "scheduler_controller_service_account_id" {
  description = "Scheduler controller service account ID"
  type        = string
  default     = "scheduler-controller"
}

variable "tag_creator_service_account_id" {
  description = "Tag creator service account ID"
  type        = string
  default     = "tag-creator"
}

variable "tag_engine_service_account_id" {
  description = "Tag engine service account ID"
  type        = string
  default     = "tag-engine"
}

variable "terraform_service_account" {
  description = "Terraform service account ID"
  type        = string
}

variable "record_manager_service_account_id" {
  description = "Record Manager service account ID"
  type        = string
  default     = "record-manager"
}

variable "report_engine_service_account_id" {
  description = "Report Engine service account ID"
  type        = string
  default     = "report-engine"
}


variable "kms_key_prevent_destroy" {
  description = "KMS key prevent destroy"
  type        = bool
  default     = true
}

variable "data_access_management_service_account_id" {
  description = "Data Access Management service account ID"
  type        = string
  default     = "data-access-management"
}

variable "dashboard_service_account_id" {
  description = "Looker dashboard service account ID"
  type        = string
  default     = "dashboard"
}

variable "encrypted_data_viewers_group" {
  description = "Consumers group for the non-confidential project"
  type        = string
}
