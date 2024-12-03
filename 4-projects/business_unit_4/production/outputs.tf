/**
 * Copyright 2021 Google LLC
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

output "data_domain_ingestion_projects" {
  description = "The data domain projects."
  value       = module.data_mesh.data_domain_ingestion_projects
}

output "data_domain_ingestion_project_kms" {
  description = "The data domain projects kms keys"
  value       = module.data_mesh.data_domain_ingestion_project_kms
}

output "data_domain_non_confidential_projects" {
  description = "The data domain non confidential projects."
  value       = module.data_mesh.data_domain_non_confidential_projects
}

output "data_domain_non_confidential_projects_kms" {
  description = "The data domain non confidential projects."
  value       = module.data_mesh.data_domain_non_confidential_projects_kms
}

output "data_domain_confidential_projects" {
  description = "The data domain confidential projects."
  value       = module.data_mesh.data_domain_confidential_projects
}

output "data_domain_confidential_projects_kms" {
  description = "The data domain confidential projects."
  value       = module.data_mesh.data_domain_confidential_projects_kms
}

output "consumer_projects" {
  description = "The consumer projects."
  value       = module.data_mesh.consumer_projects
}

output "consumer_projects_kms" {
  description = "The consumer projects kms keys"
  value       = module.data_mesh.consumer_projects_kms
}


output "dataflow_controller_service_accounts" {
  description = "The dataflow controller service accounts."
  value       = module.data_mesh.dataflow_controller_service_accounts
}

output "dataflow_controller_service_accounts_confidential" {
  description = "The dataflow controller service accounts."
  value       = module.data_mesh.dataflow_controller_service_accounts_confidential
}

output "storage_writer_service_accounts" {
  description = "The storage writer service accounts."
  value       = module.data_mesh.storage_writer_service_accounts
}

output "pubsub_writer_service_accounts" {
  description = "The pubsub writer service accounts."
  value       = module.data_mesh.pubsub_writer_service_accounts
}

output "scheduler_controller_service_accounts" {
  description = "The scheduler controller service accounts."
  value       = module.data_mesh.scheduler_controller_service_accounts
}

output "data_mesh_crypto_key_ids" {
  description = "The data mesh crypto keys."
  value       = module.data_mesh.data_mesh_crypto_key_ids
}

output "bigquery_default_service_accounts_non_confidential" {
  description = "The bigquery default service accounts."
  value       = module.data_mesh.bigquery_default_sas_non_confidential
}

output "bigquery_default_service_accounts_confidential" {
  description = "The bigquery default service accounts."
  value       = module.data_mesh.bigquery_default_sas_confidential
}

output "data_ingestion_buckets" {
  description = "The data ingestion buckets."
  value       = module.data_mesh.data_ingestion_buckets
}
