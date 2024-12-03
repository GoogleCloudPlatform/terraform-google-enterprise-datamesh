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

output "bigquery_dataset" {
  description = "Bigquery dataset resource."
  value       = module.bigquery_dataset.bigquery_dataset
}

output "bigquery_tables" {
  description = "Map of bigquery table resources being provisioned."
  value       = module.bigquery_dataset.bigquery_tables
}

output "bigquery_views" {
  description = "Map of bigquery view resources being provisioned."
  value       = module.bigquery_dataset.bigquery_views
}

output "bigquery_external_tables" {
  description = "Map of BigQuery external table resources being provisioned."
  value       = module.bigquery_dataset.bigquery_external_tables
}

output "project" {
  description = "Project where the dataset and tables are created"
  value       = module.bigquery_dataset.project
}

output "table_ids" {
  description = "Unique id for the table being provisioned"
  value       = module.bigquery_dataset.table_ids
}

output "table_names" {
  description = "Friendly name for the table being provisioned"
  value       = module.bigquery_dataset.table_names
}

output "view_ids" {
  description = "Unique id for the view being provisioned"
  value       = module.bigquery_dataset.view_ids
}

output "view_names" {
  description = "friendlyname for the view being provisioned"
  value       = module.bigquery_dataset.view_names
}

output "external_table_ids" {
  description = "Unique IDs for any external tables being provisioned"
  value       = module.bigquery_dataset.external_table_ids
}

output "external_table_names" {
  description = "Friendly names for any external tables being provisioned"
  value       = module.bigquery_dataset.external_table_ids
}

output "routine_ids" {
  description = "Unique IDs for any routine being provisioned"
  value       = module.bigquery_dataset.routine_ids
}
