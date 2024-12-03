# /**
#  * Copyright 2021 Google LLC
#  *
#  * Licensed under the Apache License, Version 2.0 (the "License");
#  * you may not use this file except in compliance with the License.
#  * You may obtain a copy of the License at
#  *
#  *      http://www.apache.org/licenses/LICENSE-2.0
#  *
#  * Unless required by applicable law or agreed to in writing, software
#  * distributed under the License is distributed on an "AS IS" BASIS,
#  * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  * See the License for the specific language governing permissions and
#  * limitations under the License.
#  */

output "default_region" {
  description = "Default region to create resources where applicable."
  value       = try(module.github_cloudbuild[0].default_region, "")
}

output "cloudbuild_project_id" {
  value = try(module.app_infra_cloudbuild_project[0].project_id, "")
}

output "app_infra_artifacts_project_id" {
  value = try(module.artifacts.project_id, "")
}

output "app_infra_artifacts_project_number" {
  value = try(module.artifacts.project_number, "")
}

output "app_infra_artifacts_kms_keys" {
  value = try(module.artifacts.kms_keys, {})
}

output "app_infra_cloudbuild_service_account_id" {
  value = module.artifacts.cloudbuild_service_account_id
}

output "github_repository_artifact_repo" {
  value = module.artifacts.github_repository_artifact_repo
}

output "github_app_installation_id" {
  value = try(var.github_app_installation_id, "")
}
output "terraform_service_accounts" {
  description = "APP Infra Pipeline Terraform Accounts."
  value       = try(module.github_cloudbuild[0].terraform_service_accounts, {})
}

output "repos" {
  description = "Cloudbuild Repos to store source code"
  value       = try(module.github_cloudbuild[0].repos, toset([]))
}

output "artifact_buckets" {
  description = "GCS Buckets to store Cloud Build Artifacts"
  value       = try(module.github_cloudbuild[0].artifact_buckets, {})
}

output "state_buckets" {
  description = "GCS Buckets to store TF state"
  value       = try(module.github_cloudbuild[0].state_buckets, {})
}

output "log_buckets" {
  description = "GCS Buckets to store Cloud Build logs"
  value       = try(module.github_cloudbuild[0].log_buckets, {})
}

output "plan_triggers_id" {
  description = "CB plan triggers"
  value       = try(module.github_cloudbuild[0].plan_triggers_id, [])
}

output "apply_triggers_id" {
  description = "CB apply triggers"
  value       = try(module.github_cloudbuild[0].apply_triggers_id, [])
}

output "enable_cloudbuild_deploy" {
  description = "Enable infra deployment using Cloud Build."
  value       = local.enable_cloudbuild_deploy
}

output "data_governance_project_id" {
  value       = module.data_governance.project_id
  description = "Data Governance Project Id"
}

output "data_governance_project_number" {
  value       = module.data_governance.project_number
  description = "Data Governance Project Number"
}

output "data_governance_project_sa" {
  value       = module.data_governance.sa
  description = "Data Governance Project Name"

}

output "data_governance_project_kms_keys" {
  value       = module.data_governance.project_keys
  description = "Keys created for the data governance project"
}

output "service_catalog_project_kms_keys" {
  value       = module.service_catalog.kms_keys
  description = "Keys created for the service catalog project"
}

output "data_governance_sa_tag_creator" {
  value       = module.data_governance.sa_tag_creator.email
  description = "Data Governance Tag Creator Service Account"
}

output "data_governance_sa_tag_engine" {
  value       = module.data_governance.sa_tag_engine.email
  description = "Data Governance Tag Engine Service Account"
}

output "data_governance_sa_cloud_run" {
  value       = module.data_governance.sa_cloud_run.email
  description = "Data Governance Cloud Run Service Account"
}

output "data_governance_sa_cloud_function" {
  value       = module.data_governance.cloud_function_service_account.email
  description = "Data Governance Cloud Function Service Account"
}

output "data_governance_sa_record_manager" {
  value       = module.data_governance.record_manager_service_account.email
  description = "Data Governance Record Manager Service Account"
}

output "data_governance_sa_report_engine" {
  value       = module.data_governance.report_engine_service_account.email
  description = "Data Governance Record Manager Service Account"
}

output "data_governance_sa_data_access_management" {
  value       = module.data_governance.data_access_management_service_account.email
  description = "Data Governance Record Manager Service Account"
}

output "data_governance_service_agent_cloud_run" {
  value       = module.data_governance.service_agent_cloud_run.email
  description = "Data Governance Cloud Run Service Agent"
}
output "data_governance_sa_scheduler_controller" {
  value       = module.data_governance.scheduler_controller_service_account.email
  description = "Data Governance Scheduler Controller Service Account"
}
output "data_governance_project_enabled_apis" {
  value       = module.data_governance.enabled_apis
  description = "Data Governance Project Enabled APIs"
}

output "app_infra_github_actions_project_id" {
  value       = module.app_infra_github_cloudbuild_project[0].project_id
  description = "App Infra Github Actions Project Id"
}

output "deidentify_keys" {
  value       = module.data_governance.deidentify_keys
  description = "Deidentify keys"
}

output "bq_keys" {
  value       = module.data_governance.bq_keys
  description = "Keys for BQ in Data Governance"
}

output "fs_keys" {
  value       = module.data_governance.fs_keys
  description = "Keys for FS in Data Governance"
}

output "kms_wrapper_secret_name" {
  value       = local.kms_wrapper_secret_name
  description = "KMS Wrapper Secret Name"
}

output "common_secrets_project_id" {
  value       = local.common_secrets_project_id
  description = "Common Secrets Project Id"
}

# output "app_infra_github_registry_repositories" {
#   value       = try({ for repo in local.registry_repository_types : repo.format => google_artifact_registry_repository.repository[repo.format].name }, {})
#   description = "App Infra Github Registry Repositories"
# }

output "dlp_kms_wrapper_secret_name" {
  value       = local.dlp_kms_wrapper_secret_name
  description = "DLP KMS Wrapper Secret Id"
}

output "tag_engine_oauth_client_id_secret_name" {
  value       = local.tag_engine_oauth_client_id_secret
  description = "Tag Engine OAuth Client Id Secret Id"
}

output "service_catalog" {
  value = try(module.service_catalog, "")
}

output "data_governance_tf_state_bucket" {
  description = "data governance TF state bucket"
  value       = module.github_cloudbuild[0].state_buckets["data-governance"]
}

output "data_viewer_groups_email" {
  description = "All data viewer groups"
  value = {
    data_viewer              = var.consumer_groups.non_confidential_data_viewer
    encrypted_data_viewer    = var.consumer_groups.non_confidential_encrypted_data_viewer
    fine_grained_data_viewer = var.consumer_groups.non_confidential_fine_grained_data_viewer
    masked_data_viewer       = var.consumer_groups.non_confidential_masked_data_viewer
    conf_data_viewer         = var.consumer_groups.confidential_data_viewer
  }
}
