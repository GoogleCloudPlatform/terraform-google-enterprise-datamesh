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

resource "google_bigquery_table" "default" {
  project    = var.project_id
  dataset_id = var.dataset_id
  table_id   = var.table_id
  schema     = var.schema

  labels = var.labels
  # Optional settings (set to defaults)
  deletion_protection = var.deletion_protection
  expiration_time     = var.expiration_time

  encryption_configuration {
    kms_key_name = data.google_kms_crypto_key.key.id
  }
}
