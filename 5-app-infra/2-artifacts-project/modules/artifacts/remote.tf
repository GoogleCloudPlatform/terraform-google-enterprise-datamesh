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
  billing_account                          = data.terraform_remote_state.bootstrap.outputs.common_config.billing_account
  common_secrets_project_id                = data.terraform_remote_state.org.outputs.org_secrets_project_id
  gh_token_secret                          = data.terraform_remote_state.org.outputs.gh_token_secret
  tag_engine_oauth_client_id_secret_name   = data.terraform_remote_state.org.outputs.tag_engine_oauth_client_id_secret
  github_repository_artifact_repo          = data.terraform_remote_state.business_unit_shared.outputs.github_repository_artifact_repo["artifact-repo"]
  app_infra_artifacts_kms_keys             = data.terraform_remote_state.business_unit_shared.outputs.app_infra_artifacts_kms_keys
  app_infra_cloudbuild_service_account_id  = data.terraform_remote_state.business_unit_shared.outputs.app_infra_cloudbuild_service_account_id
  dataflow_controller_sa_ingestion_dev     = data.terraform_remote_state.business_unit_developement.outputs.dataflow_controller_service_accounts
  dataflow_controller_sa_confidential_dev  = data.terraform_remote_state.business_unit_developement.outputs.dataflow_controller_service_accounts_confidential
  dataflow_controller_sa_ingestion_nonp    = data.terraform_remote_state.business_unit_nonproduction.outputs.dataflow_controller_service_accounts
  dataflow_controller_sa_confidential_nonp = data.terraform_remote_state.business_unit_nonproduction.outputs.dataflow_controller_service_accounts_confidential
  dataflow_controller_sa_ingestion_prod    = data.terraform_remote_state.business_unit_production.outputs.dataflow_controller_service_accounts
  dataflow_controller_sa_confidential_prod = data.terraform_remote_state.business_unit_production.outputs.dataflow_controller_service_accounts_confidential
  cloudrun_service_agent_data_governance   = data.terraform_remote_state.business_unit_shared.outputs.data_governance_service_agent_cloud_run
  data_domain_ingestion_projects           = data.terraform_remote_state.business_unit_developement.outputs.data_domain_ingestion_projects
}

data "terraform_remote_state" "bootstrap" {
  backend = "gcs"

  config = {
    bucket = var.remote_state_bucket
    prefix = "terraform/bootstrap/state"
  }
}
data "terraform_remote_state" "business_unit_shared" {
  backend = "gcs"

  config = {
    bucket = var.remote_state_bucket
    prefix = "terraform/projects/${var.business_unit}/shared"
  }
}

data "terraform_remote_state" "business_unit_developement" {
  backend = "gcs"

  config = {
    bucket = var.remote_state_bucket
    prefix = "terraform/projects/${var.business_unit}/development"
  }
}

data "terraform_remote_state" "business_unit_nonproduction" {
  backend = "gcs"

  config = {
    bucket = var.remote_state_bucket
    prefix = "terraform/projects/${var.business_unit}/nonproduction"
  }
}

data "terraform_remote_state" "business_unit_production" {
  backend = "gcs"

  config = {
    bucket = var.remote_state_bucket
    prefix = "terraform/projects/${var.business_unit}/production"
  }
}

data "terraform_remote_state" "org" {
  backend = "gcs"

  config = {
    bucket = var.remote_state_bucket
    prefix = "terraform/org/state"
  }
}
