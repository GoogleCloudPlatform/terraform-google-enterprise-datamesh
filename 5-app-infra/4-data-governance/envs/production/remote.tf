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
  organization_id                                     = data.terraform_remote_state.org.outputs.org_id
  common_secrets_project_id                           = data.terraform_remote_state.org.outputs.org_secrets_project_id
  dlp_kms_wrapper_secret_name                         = data.terraform_remote_state.org.outputs.dlp_kms_wrapper_secret
  data_governance_project_id                          = data.terraform_remote_state.business_unit_shared.outputs.data_governance_project_id
  data_governance_kms_key                             = data.terraform_remote_state.business_unit_shared.outputs.data_governance_project_kms_keys["project_key_common-${var.region}"]
  terraform_service_accounts                          = data.terraform_remote_state.business_unit_shared.outputs.terraform_service_accounts
  bq_data_quality_kms_key                             = data.terraform_remote_state.business_unit_shared.outputs.bq_keys["data_quality_bigquery_${var.environment}-${var.region}"]
  bq_tag_history_kms_key                              = data.terraform_remote_state.business_unit_shared.outputs.bq_keys["tag_history_bigquery_${var.environment}-${var.region}"]
  deidentify_kms_key                                  = data.terraform_remote_state.business_unit_shared.outputs.deidentify_keys["deidenfication_key_${var.environment}-${var.region}"]
  artifact_project_id                                 = data.terraform_remote_state.business_unit_shared.outputs.app_infra_artifacts_project_id
  cloud_run_sa                                        = data.terraform_remote_state.business_unit_shared.outputs.data_governance_sa_cloud_run
  cloud_function_sa                                   = data.terraform_remote_state.business_unit_shared.outputs.data_governance_sa_cloud_function
  record_manager_sa                                   = data.terraform_remote_state.business_unit_shared.outputs.data_governance_sa_record_manager
  report_engine_sa                                    = data.terraform_remote_state.business_unit_shared.outputs.data_governance_sa_report_engine
  data_access_management_sa                           = data.terraform_remote_state.business_unit_shared.outputs.data_governance_sa_data_access_management
  data_domain_non_conf_projects_dev                   = data.terraform_remote_state.business_unit_env_dev.outputs.data_domain_non_confidential_projects
  data_domain_non_conf_projects_nonp                  = data.terraform_remote_state.business_unit_env_nonp.outputs.data_domain_non_confidential_projects
  data_domain_non_conf_projects_prod                  = data.terraform_remote_state.business_unit_env_prod.outputs.data_domain_non_confidential_projects
  dataflow_controller_service_accounts_dev            = data.terraform_remote_state.business_unit_env_dev.outputs.dataflow_controller_service_accounts_confidential
  dataflow_controller_service_accounts_nonp           = data.terraform_remote_state.business_unit_env_nonp.outputs.dataflow_controller_service_accounts_confidential
  dataflow_controller_service_accounts_prod           = data.terraform_remote_state.business_unit_env_prod.outputs.dataflow_controller_service_accounts_confidential
  bigquery_default_service_accounts_confidential_dev  = data.terraform_remote_state.business_unit_env_dev.outputs.bigquery_default_service_accounts_confidential
  bigquery_default_service_accounts_confidential_nonp = data.terraform_remote_state.business_unit_env_nonp.outputs.bigquery_default_service_accounts_confidential
  bigquery_default_service_accounts_confidential_prod = data.terraform_remote_state.business_unit_env_prod.outputs.bigquery_default_service_accounts_confidential
  data_governance_sa_tag_creator                      = data.terraform_remote_state.business_unit_shared.outputs.data_governance_sa_tag_creator
  data_governance_sa_tag_engine                       = data.terraform_remote_state.business_unit_shared.outputs.data_governance_sa_tag_engine
  consumer_groups_email                               = data.terraform_remote_state.business_unit_shared.outputs.data_viewer_groups_email
}

data "terraform_remote_state" "business_unit_shared" {
  backend = "gcs"

  config = {
    bucket = var.remote_state_bucket
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

data "terraform_remote_state" "business_unit_env_dev" {
  backend = "gcs"

  config = {
    bucket = var.remote_state_bucket
    prefix = "terraform/projects/${var.business_unit}/development"
  }
}

data "terraform_remote_state" "business_unit_env_nonp" {
  backend = "gcs"

  config = {
    bucket = var.remote_state_bucket
    prefix = "terraform/projects/${var.business_unit}/nonproduction"
  }
}

data "terraform_remote_state" "business_unit_env_prod" {
  backend = "gcs"

  config = {
    bucket = var.remote_state_bucket
    prefix = "terraform/projects/${var.business_unit}/production"
  }
}

# data "terraform_remote_state" "network_env" {
#   backend = "gcs"

#   config = {
#     bucket = var.remote_state_bucket
#     prefix = "terraform/networks/${var.env}"
#   }
# }
