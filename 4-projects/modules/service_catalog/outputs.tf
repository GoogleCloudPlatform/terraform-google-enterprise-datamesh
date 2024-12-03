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
  value       = module.service_catalog_project.project_id
  description = "Data Governance Project Id"
}

output "project_number" {
  value       = module.service_catalog_project.project_number
  description = "Data Governance Project Number"
}

output "sa" {
  value       = module.service_catalog_project.sa
  description = "Data Governance Project Name"
}

output "kms_keys" {
  description = "KMS keys from the service catalog project"
  value       = [for k in toset(var.shared_kms_key_ring) : module.service_catalog_project_kms[k].kms_key]
}
output "enabled_apis" {
  value       = module.service_catalog_project.enabled_apis
  description = "Data Governance Project Enabled APIs"
}

