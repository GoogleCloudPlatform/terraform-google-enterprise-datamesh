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
  value       = module.bigquery_dataset.bigquery_dataset
  description = "Bigquery dataset resource."
}

output "bigquery_tables" {
  value       = module.bigquery_dataset.bigquery_tables
  description = "Map of bigquery table resources being provisioned."
}

output "bigquery_views" {
  value       = module.bigquery_dataset.bigquery_views
  description = "Map of bigquery view resources being provisioned."
}

output "bigquery_external_tables" {
  value       = module.bigquery_dataset.bigquery_external_tables
  description = "Map of BigQuery external table resources being provisioned."
}

output "project" {
  value       = module.bigquery_dataset.project
  description = "Project where the dataset and tables are created"
}

output "table_ids" {
  value       = module.bigquery_dataset.table_ids
  description = "Unique id for the table being provisioned"
}

output "table_names" {
  value       = module.bigquery_dataset.table_names
  description = "Friendly name for the table being provisioned"
}

output "view_ids" {
  value       = module.bigquery_dataset.view_ids
  description = "Unique id for the view being provisioned"
}

output "view_names" {
  value       = module.bigquery_dataset.view_names
  description = "friendlyname for the view being provisioned"
}

output "external_table_ids" {
  value       = module.bigquery_dataset.external_table_ids
  description = "Unique IDs for any external tables being provisioned"
}

output "external_table_names" {
  value       = module.bigquery_dataset.external_table_ids
  description = "Friendly names for any external tables being provisioned"
}

output "routine_ids" {
  value       = module.bigquery_dataset.routine_ids
  description = "Unique IDs for any routine being provisioned"
}
