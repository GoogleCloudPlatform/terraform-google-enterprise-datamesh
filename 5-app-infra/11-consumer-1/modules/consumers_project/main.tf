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


module "bigquery" {
  source = "../bigquery"

  project_id   = local.consumer_project
  dataset_id   = var.bigquery_dataset_id
  dataset_name = var.bigquery_dataset_name
  description  = var.bigquery_description
  tables       = var.bigquery_tables
  location     = var.bigquery_location

  external_tables = var.bigquery_external_tables

  delete_contents_on_destroy = var.bigquery_delete_contents_on_destroy
  deletion_protection        = var.bigquery_deletion_protection

  default_table_expiration_ms = var.bigquery_default_table_expiration_ms
  max_time_travel_hours       = var.bigquery_max_time_travel_hours

  encryption_key = local.bigquery_key_name

  access             = var.bigquery_access
  views              = var.bigquery_views
  materialized_views = var.biugquery_materialized_views

  routines = var.bigquery_routines

  dataset_labels = merge({
    environment   = var.env
    consumer      = var.consumer_name
    business_unit = var.business_unit
  }, var.additional_bigquery_dataset_labels)
}
