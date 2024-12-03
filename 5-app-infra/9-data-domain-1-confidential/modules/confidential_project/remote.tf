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
  projects_backend_bucket              = data.terraform_remote_state.bootstrap.outputs.projects_gcs_bucket_tfstate
  logging_bucket_name                  = data.terraform_remote_state.org.outputs.logs_export_storage_bucket_name
  kms_project_id                       = data.terraform_remote_state.org.outputs.common_kms_project_id
  data_domain_confidential_project     = data.terraform_remote_state.business_unit_env.outputs.data_domain_confidential_projects[var.domain_name].project_id
  data_domain_non_confidential_project = data.terraform_remote_state.business_unit_env.outputs.data_domain_non_confidential_projects[var.domain_name].project_id
  bigquery_key_name                    = data.terraform_remote_state.business_unit_env.outputs.data_mesh_crypto_key_ids[var.domain_name]["confidential_bigquery_key_${var.business_code}_${var.domain_name}_${var.env}-${var.keyring_region}"]
  restricted_network_name              = data.terraform_remote_state.network_env.outputs.restricted_network_name
  restricted_subnets_names             = data.terraform_remote_state.network_env.outputs.restricted_subnets_names
  restricted_host_project_id           = data.terraform_remote_state.network_env.outputs.restricted_host_project_id
  data_governance_project_id           = data.terraform_remote_state.business_unit_shared.outputs.data_governance_project_id
  app_infra_artifacts_project_id       = data.terraform_remote_state.business_unit_shared.outputs.app_infra_artifacts_project_id
  dataflow_controller_service_account  = data.terraform_remote_state.business_unit_env.outputs.dataflow_controller_service_accounts_confidential[var.domain_name]
  dlp_deidentify_template_id           = data.terraform_remote_state.data_governance.outputs.dlp_deidentify_template_id
}

data "terraform_remote_state" "bootstrap" {
  backend = "gcs"

  config = {
    bucket = var.remote_state_bucket
    prefix = "terraform/bootstrap/state"
  }
}

data "terraform_remote_state" "org" {
  backend = "gcs"

  config = {
    bucket = var.remote_state_bucket
    prefix = "terraform/org/state"
  }
}

data "terraform_remote_state" "network_env" {
  backend = "gcs"

  config = {
    bucket = var.remote_state_bucket
    prefix = "terraform/networks/${var.env}"
  }
}


data "terraform_remote_state" "business_unit_shared" {
  backend = "gcs"

  config = {
    bucket = local.projects_backend_bucket
    prefix = "terraform/projects/${var.business_unit}/shared"
  }
}

data "terraform_remote_state" "business_unit_env" {
  backend = "gcs"

  config = {
    bucket = local.projects_backend_bucket
    prefix = "terraform/projects/${var.business_unit}/${var.env}"
  }
}

data "terraform_remote_state" "data_governance" {
  backend = "gcs"

  config = {
    bucket = var.data_governance_state_bucket
    prefix = "terraform/production"
  }
}
