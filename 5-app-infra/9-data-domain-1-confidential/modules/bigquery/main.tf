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

module "bigquery_dataset" {
  source  = "terraform-google-modules/bigquery/google"
  version = "~> 7.0"

  project_id                  = var.project_id
  dataset_labels              = var.dataset_labels
  dataset_id                  = var.dataset_id
  dataset_name                = var.dataset_name
  description                 = var.description
  location                    = var.location
  encryption_key              = var.encryption_key
  delete_contents_on_destroy  = var.delete_contents_on_destroy
  default_table_expiration_ms = var.default_table_expiration_ms

  deletion_protection   = var.deletion_protection
  max_time_travel_hours = var.max_time_travel_hours

  access = var.access

  tables             = var.tables
  views              = var.views
  materialized_views = var.materialized_views

  external_tables = var.external_tables
  routines        = var.routines
}
