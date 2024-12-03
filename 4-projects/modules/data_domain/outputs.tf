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

output "ingestion_project" {
  value = module.ingestion_project
}

output "nonconfidential_project" {
  value = module.nonconfidential_project
}

output "confidential_project" {
  value = module.confidential_project
}

output "kms_keys" {
  value = {
    ingestion       = { for location in keys(local.keyrings) : location => module.ingestion_project_keys[location].kms_key }
    nonconfidential = { for location in keys(local.keyrings) : location => module.nonconfidential_project_keys[location].kms_key }
    confidential    = { for location in keys(local.keyrings) : location => module.confidential_project_keys[location].kms_key }
  }
}

output "service_accounts" {
  value = {
    ingestion       = google_service_account.ingestion_service_accounts
    nonconfidential = {}
    confidential    = google_service_account.confidential_service_accounts
  }
}

output "data_mesh_crypto_key_ids" {
  description = "The data mesh crypto keys."
  value       = { for key_ring in local.key_sa_map : "${key_ring.key}-${key_ring.location}" => module.data_mesh_keys["${key_ring.key}-${key_ring.location}"].kms_key.id }
}

output "nonconfidential_bigquery_sa" {
  value = data.google_bigquery_default_service_account.nonconfidential_bigquery_sa
}

output "confidential_bigquery_sa" {
  value = data.google_bigquery_default_service_account.confidential_bigquery_sa
}

output "data_ingestion_bucket" {
  value = google_storage_bucket.data_ingestion_bucket
}
