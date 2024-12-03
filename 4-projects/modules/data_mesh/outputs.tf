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


output "data_domain_ingestion_projects" {
  description = "The data domain projects."
  value       = { for d in var.data_domains : d.name => module.data_domain_projects[d.name].ingestion_project }
}

output "data_domain_ingestion_project_kms" {
  description = "The data domain projects kms keys"
  value       = { for d in var.data_domains : d.name => module.data_domain_projects[d.name].kms_keys.ingestion }
}

output "data_domain_non_confidential_projects" {
  description = "The data domain non confidential projects."
  value       = { for d in var.data_domains : d.name => module.data_domain_projects[d.name].nonconfidential_project }
}

output "data_domain_non_confidential_projects_kms" {
  description = "The data domain non confidential projects."
  value       = { for d in var.data_domains : d.name => module.data_domain_projects[d.name].kms_keys.nonconfidential }
}

output "data_domain_confidential_projects" {
  description = "The data domain confidential projects."
  value       = { for d in var.data_domains : d.name => module.data_domain_projects[d.name].confidential_project }
}

output "data_domain_confidential_projects_kms" {
  description = "The data domain confidential projects."
  value       = { for d in var.data_domains : d.name => module.data_domain_projects[d.name].kms_keys.confidential }
}

output "consumer_projects" {
  description = "The consumer projects."
  value       = { for project in var.consumers_projects : project.name => module.consumers_projects[project.name].consumer_project }
}

output "consumer_projects_kms" {
  description = "The consumer projects kms keys"
  value       = { for project in var.consumers_projects : project.name => module.consumers_projects[project.name].kms_keys }
}

output "dataflow_controller_service_accounts" {
  description = "The dataflow controller service accounts."
  value       = { for d in var.data_domains : d.name => module.data_domain_projects[d.name].service_accounts.ingestion["sa-dataflow-controller"].email }
}

output "dataflow_controller_service_accounts_confidential" {
  description = "The dataflow controller service accounts."
  value       = { for d in var.data_domains : d.name => module.data_domain_projects[d.name].service_accounts.confidential["sa-dataflow-controller-reid"].email }
}

output "storage_writer_service_accounts" {
  description = "The storage writer service accounts."
  value       = { for d in var.data_domains : d.name => module.data_domain_projects[d.name].service_accounts.ingestion["sa-storage-writer"].email }
}

output "pubsub_writer_service_accounts" {
  description = "The pubsub writer service accounts."
  value       = { for d in var.data_domains : d.name => module.data_domain_projects[d.name].service_accounts.ingestion["sa-pubsub-writer"].email }
}

output "scheduler_controller_service_accounts" {
  description = "The scheduler controller service accounts."
  value       = { for d in var.data_domains : d.name => module.data_domain_projects[d.name].service_accounts.ingestion["sa-scheduler-controller"].email }
}

output "data_mesh_crypto_key_ids" {
  description = "The data mesh crypto keys."
  value       = { for d in var.data_domains : d.name => module.data_domain_projects[d.name].data_mesh_crypto_key_ids }
}

output "bigquery_default_sas_non_confidential" {
  description = "BigQuery Default Service Acounts - Non Confidential"
  value       = { for d in var.data_domains : d.name => module.data_domain_projects[d.name].nonconfidential_bigquery_sa.email }
}

output "bigquery_default_sas_confidential" {
  description = "BigQuery Default Service Acounts - Confidential"
  value       = { for d in var.data_domains : d.name => module.data_domain_projects[d.name].confidential_bigquery_sa.email }
}

output "data_ingestion_buckets" {
  description = "The data ingestion buckets."
  value       = { for d in var.data_domains : d.name => module.data_domain_projects[d.name].data_ingestion_bucket.url }
}
