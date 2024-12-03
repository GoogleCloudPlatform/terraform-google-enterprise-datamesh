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

output "project_id" {
  value       = module.data_governance_project.project_id
  description = "Data Governance Project Id"
}

output "project_number" {
  value       = module.data_governance_project.project_number
  description = "Data Governance Project Number"
}

output "sa" {
  value       = module.data_governance_project.sa
  description = "Data Governance Project Name"
}

# output "kms_keys" {
#   value       = module.data_governance_project.kms_keys
#   description = "Keys created for the data governance project"
# }

output "enabled_apis" {
  value       = module.data_governance_project.enabled_apis
  description = "Data Governance Project Enabled APIs"
}

output "sa_tag_creator" {
  value       = google_service_account.tag_creator
  description = "Data Governance Tag Creator Service Account"
}

output "sa_tag_engine" {
  value       = google_service_account.tag_engine
  description = "Data Governance Tag Engine Service Account"
}

output "sa_cloud_run" {
  value       = google_service_account.cloud_run
  description = "Data Governance Cloud Run Service Account"
}

output "service_agent_cloud_run" {
  value       = google_project_service_identity.identity["run.googleapis.com"]
  description = "Data Governance Cloud Run Service Agent"
}

output "scheduler_controller_service_account" {
  value       = google_service_account.scheduler_controller_service_account
  description = "Data Governance Scheduler Controller Service Account"
}

output "cloud_function_service_account" {
  value       = google_service_account.cloud_function
  description = "Data Governance Cloud Function Service Account"
}

output "record_manager_service_account" {
  value       = google_service_account.record_manager_service_account
  description = "Data Governance Record Manager Service Account"
}

output "report_engine_service_account" {
  value       = google_service_account.report_engine_service_account
  description = "Data Governance Report Engine Service Account"
}

output "data_access_management_service_account" {
  value       = google_service_account.data_access_management_service_account
  description = "Data Governance Data Access Manager Service Account"
}

output "project_keys" {
  value       = try({ for key_ring in local.shared_key_sa_map : "${key_ring.key}-${key_ring.location}" => module.data_governance_keys["${key_ring.key}-${key_ring.location}"].kms_key.id if key_ring.type == "project" }, {})
  description = "Project keys"
}

output "deidentify_keys" {
  value       = try({ for key_ring in local.shared_key_sa_map : "${key_ring.key}-${key_ring.location}" => module.data_governance_keys["${key_ring.key}-${key_ring.location}"].kms_key.id if key_ring.type == "kek" }, {})
  description = "Deidentify keys"
}

output "bq_keys" {
  value       = try({ for key_ring in local.shared_key_sa_map : "${key_ring.key}-${key_ring.location}" => module.data_governance_keys["${key_ring.key}-${key_ring.location}"].kms_key.id if key_ring.type == "bq_encrypt" }, {})
  description = "Keys for BQ in Data Governance"
}

output "fs_keys" {
  value       = try({ for key_ring in local.shared_key_sa_map : "${key_ring.key}-${key_ring.location}" => module.data_governance_keys["${key_ring.key}-${key_ring.location}"].kms_key.id if key_ring.type == "fs_encrypt" }, {})
  description = "Keys for Firestore in Data Governance"
}
