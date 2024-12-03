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

output "common_service_perimeter" {
  value = local.common_service_perimeter
}

output "access_context_manager_policy_id" {
  value = local.access_context_manager_policy_id
}

output "development_service_perimeter" {
  value = local.development_service_perimeter
}

output "nonprod_service_perimeter" {
  value = local.nonprod_service_perimeter
}

output "production_service_perimeter" {
  value = local.production_service_perimeter
}

output "common_shared_restricted_project_number" {
  value = local.common_shared_restricted_project_number
}

output "development_shared_restricted_project_number" {
  value = local.development_shared_restricted_project_number
}

output "nonprod_shared_restricted_project_number" {
  value = local.nonprod_shared_restricted_project_number
}

output "production_shared_restricted_project_number" {
  value = local.production_shared_restricted_project_number
}

output "common_kms_project_number" {
  value = local.common_kms_project_number
}

output "development_kms_project_number" {
  value = local.development_kms_project_number
}

output "nonprod_kms_project_number" {
  value = local.nonprod_kms_project_number
}

output "production_kms_project_number" {
  value = local.production_kms_project_number
}

output "common_secrets_project_number" {
  value = local.common_secrets_project_number
}

output "common_audit_logs_project_number" {
  value = data.google_project.audit_logs_project.number
}

output "data_governance_project_number" {
  value = local.data_governance_project_number
}

output "data_governance_project_id" {
  value = local.data_governance_project_id
}

output "artifacts_project_number" {
  value = local.artifacts_project_number
}

output "tf_sa_data_domain_1_non_conf_sa" {
  value = local.tf_sa_data_domain_1_non_conf_sa
}

output "tf_sa_data_domain_1_conf_sa" {
  value = local.tf_sa_data_domain_1_conf_sa
}

output "tf_sa_data_domain_1_ingest_sa" {
  value = local.tf_sa_data_domain_1_ingest_sa
}
output "tf_sa_data_governance_sa" {
  value = local.tf_sa_data_governance_sa
}

output "dev_data_domain_1_non_conf" {
  value = local.dev_data_domain_1_non_conf
}

output "dev_data_domain_1_non_conf_id" {
  value = local.dev_data_domain_1_non_conf_id
}

output "dev_data_domain_1_conf" {
  value = local.dev_data_domain_1_conf
}

output "dev_data_domain_1_conf_id" {
  value = local.dev_data_domain_1_conf_id
}

output "nonprod_data_domain_1_non_conf" {
  value = local.nonprod_data_domain_1_non_conf
}

output "nonprod_data_domain_1_conf" {
  value = local.nonprod_data_domain_1_conf
}

output "nonprod_data_domain_1_conf_id" {
  value = local.nonprod_data_domain_1_conf_id
}

output "prod_data_domain_1_non_conf" {
  value = local.prod_data_domain_1_non_conf
}

output "prod_data_domain_1_conf" {
  value = local.prod_data_domain_1_conf
}

output "prod_data_domain_1_conf_id" {
  value = local.prod_data_domain_1_conf_id
}

output "dev_data_domain_1_ingest" {
  value = local.dev_data_domain_ingest
}

output "dev_data_domain_1_ingest_id" {
  value = local.dev_data_domain_ingest_id
}

output "nonprod_data_domain_1_ingest" {
  value = local.nonprod_data_domain_ingest
}

output "nonprod_data_domain_1_ingest_id" {
  value = local.nonprod_data_domain_ingest_id
}

output "prod_data_domain_1_ingest" {
  value = local.prod_data_domain_ingest
}

output "prod_data_domain_1_ingest_id" {
  value = local.prod_data_domain_ingest_id
}

output "tf_sa_service_catalog" {
  value = local.tf_sa_service_catalog
}

output "service_catalog_project_number" {
  value = local.service_catalog_project_number
}

output "dev_consumer_1" {
  value = local.dev_consumer_1
}

output "nonprod_consumer_1" {
  value = local.nonprod_consumer_1
}

output "prod_consumer_1" {
  value = local.prod_consumer_1
}

output "data_viewer_group" {
  value = local.data_viewer_groups["data_viewer"]
}

output "encrypted_data_viewer_group" {
  value = local.data_viewer_groups["encrypted_data_viewer"]
}

output "fine_grained_viewer_group" {
  value = local.data_viewer_groups["fine_grained_data_viewer"]
}

output "masked_data_viewer_group" {
  value = local.data_viewer_groups["masked_data_viewer"]
}

output "conf_data_viewer_group" {
  value = local.data_viewer_groups["conf_data_viewer"]
}
