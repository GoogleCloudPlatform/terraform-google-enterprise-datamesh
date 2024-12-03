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

output "sensitive_tag_ids_development" {
  description = "Sensitive Tag IDs for each development domain"
  value       = try(distinct([for domain in var.dlp_job_inspect_datasets : module.data_catalog_development[domain.domain_name].sensitive_tag_ids]), [])
}

output "sensitive_tag_ids_nonproduction" {
  description = "values of sensitive tag ids for each non production domain"
  value       = try(distinct([for domain in var.dlp_job_inspect_datasets : module.data_catalog_nonproduction[domain.domain_name].sensitive_tag_ids]), [])
}

output "sensitive_tag_ids_production" {
  description = "values of sensitive tag ids for each production domain"
  value       = try(distinct([for domain in var.dlp_job_inspect_datasets : module.data_catalog_production[domain.domain_name].sensitive_tag_ids]), [])
}

output "dlp_deidentify_template_id" {
  description = "DLP Deidentify template id"
  value       = module.data_de_identification_template.dlp_deidentify_template_id
}

output "tag_engine_config_response_development" {
  description = "Tag Engine responses for each development domain"
  value       = module.tag_engine_development.tag_engine_config_response
}

output "tag_engine_config_response_nonproduction" {
  description = "Tag Engine responses for each development domain"
  value       = module.tag_engine_nonproduction.tag_engine_config_response
}

output "tag_engine_config_response_production" {
  description = "Tag Engine responses for each development domain"
  value       = module.tag_engine_production.tag_engine_config_response
}
