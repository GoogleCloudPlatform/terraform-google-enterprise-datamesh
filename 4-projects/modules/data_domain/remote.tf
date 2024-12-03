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

locals {
  org_id                  = data.terraform_remote_state.bootstrap.outputs.common_config.org_id
  billing_account         = data.terraform_remote_state.bootstrap.outputs.common_config.billing_account
  project_prefix          = data.terraform_remote_state.bootstrap.outputs.common_config.project_prefix
  projects_backend_bucket = data.terraform_remote_state.bootstrap.outputs.projects_gcs_bucket_tfstate
  perimeter_name          = data.terraform_remote_state.network_env.outputs.restricted_service_perimeter_name
  # base_network_self_link              = data.terraform_remote_state.network_env.outputs.base_network_self_link
  # base_subnets_self_links             = data.terraform_remote_state.network_env.outputs.base_subnets_self_links
  # base_host_project_id                = data.terraform_remote_state.network_env.outputs.base_host_project_id
  restricted_host_project_id       = data.terraform_remote_state.network_env.outputs.restricted_host_project_id
  restricted_subnets_self_links    = data.terraform_remote_state.network_env.outputs.restricted_subnets_self_links
  access_context_manager_policy_id = data.terraform_remote_state.network_env.outputs.access_context_manager_policy_id
  env_kms_project_id               = data.terraform_remote_state.environments_env.outputs.env_kms_project_id
  # env_folder_name                     = data.terraform_remote_state.environments_env.outputs.env_folder
  # env_kms_key_keyrings                = data.terraform_remote_state.environments_env.outputs.key_rings
  app_infra_pipeline_service_accounts = data.terraform_remote_state.business_unit_shared.outputs.terraform_service_accounts
  # enable_cloudbuild_deploy            = data.terraform_remote_state.business_unit_shared.outputs.enable_cloudbuild_deploy
  data_governance_project_number    = data.terraform_remote_state.business_unit_shared.outputs.data_governance_project_number
  data_governance_project_id        = data.terraform_remote_state.business_unit_shared.outputs.data_governance_project_id
  data_governance_sa_cloud_run      = data.terraform_remote_state.business_unit_shared.outputs.data_governance_sa_cloud_run
  data_governance_sa_cloud_function = data.terraform_remote_state.business_unit_shared.outputs.data_governance_sa_cloud_function
  data_governance_sa_tag_creator    = data.terraform_remote_state.business_unit_shared.outputs.data_governance_sa_tag_creator
  data_governance_sa_report_engine  = data.terraform_remote_state.business_unit_shared.outputs.data_governance_sa_report_engine
  data_governance_sa_record_manager = data.terraform_remote_state.business_unit_shared.outputs.data_governance_sa_record_manager
  app_infra_artifacts_project_id    = data.terraform_remote_state.business_unit_shared.outputs.app_infra_artifacts_project_id
  deidentify_keys                   = data.terraform_remote_state.business_unit_shared.outputs.deidentify_keys
  data_governance_tf_state_bucket   = data.terraform_remote_state.business_unit_shared.outputs.data_governance_tf_state_bucket
  shared_kms_key_ring               = data.terraform_remote_state.org.outputs.key_rings
  shared_kms_project_id             = data.terraform_remote_state.org.outputs.common_kms_project_id
  common_secrets_project_id         = data.terraform_remote_state.org.outputs.org_secrets_project_id
  kms_wrapper_secret_name           = data.terraform_remote_state.org.outputs.kms_wrapper_secret
  common_logs_project_id            = data.terraform_remote_state.org.outputs.org_audit_logs_project_id
  logs_export_storage_bucket_name   = data.terraform_remote_state.org.outputs.logs_export_storage_bucket_name
}

data "terraform_remote_state" "bootstrap" {
  backend = "gcs"

  config = {
    bucket = var.remote_state_bucket
    prefix = "terraform/bootstrap/state"
  }
}

data "terraform_remote_state" "network_env" {
  backend = "gcs"

  config = {
    bucket = var.remote_state_bucket
    prefix = "terraform/networks/${var.env}"
  }
}

data "terraform_remote_state" "environments_env" {
  backend = "gcs"

  config = {
    bucket = var.remote_state_bucket
    prefix = "terraform/environments/${var.env}"
  }
}

data "terraform_remote_state" "business_unit_shared" {
  backend = "gcs"

  config = {
    bucket = local.projects_backend_bucket
    prefix = "terraform/projects/${var.business_unit}/shared"
  }
}

data "terraform_remote_state" "org" {
  backend = "gcs"

  config = {
    bucket = var.remote_state_bucket
    prefix = "terraform/org/state"
  }
}
