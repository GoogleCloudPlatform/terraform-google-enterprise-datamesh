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

output "table_ids" {
  value       = module.bigquery.table_ids
  description = "Unique id for the table being provisioned"
}

output "table_names" {
  value       = module.bigquery.table_names
  description = "Friendly name for the table being provisioned"
}

output "bigquery_dataset" {
  value       = module.bigquery.bigquery_dataset
  description = "The created bigquery dataset"
}

output "bigquery_tables" {
  value       = module.bigquery.bigquery_tables
  description = "Map of created bigquery tables"
}

output "bigquery_external_tables" {
  value       = module.bigquery.bigquery_external_tables
  description = "Map of created bigquery external tables"
}

output "view_names" {
  value       = module.bigquery.view_names
  description = "Friendly name for the view being provisioned"
}

output "external_table_names" {
  value       = module.bigquery.external_table_names
  description = "Friendly name for the external table being provisioned"
}

output "external_table_ids" {
  value       = module.bigquery.external_table_ids
  description = "Unique id for the external table being provisioned"
}

output "routine_ids" {
  value       = module.bigquery.routine_ids
  description = "Unique id for the routine being provisioned"
}
