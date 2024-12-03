/**
 * Copyright 2022 Google LLC
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
  common_secrets_project_id           = data.terraform_remote_state.org.outputs.org_secrets_project_id
  kms_wrapper_secret_name             = data.terraform_remote_state.org.outputs.kms_wrapper_secret
  shared_kms_project_id               = data.terraform_remote_state.org.outputs.common_kms_project_id
  logging_bucket_name                 = data.terraform_remote_state.org.outputs.logs_export_storage_bucket_name
  env_kms_project_id                  = data.terraform_remote_state.env.outputs.env_kms_project_id
  deidentify_kms_key                  = data.terraform_remote_state.business_unit_shared.outputs.deidentify_keys["deidenfication_key_common-${var.region}"]
  projects_backend_bucket             = data.terraform_remote_state.bootstrap.outputs.projects_gcs_bucket_tfstate
  dataflow_controller_service_account = data.terraform_remote_state.business_unit_env.outputs.dataflow_controller_service_accounts[var.domain_name]
  pubsub_writer_service_account       = data.terraform_remote_state.business_unit_env.outputs.pubsub_writer_service_accounts[var.domain_name]
  data_ingestion_bucket               = data.terraform_remote_state.business_unit_env.outputs.data_ingestion_buckets[var.domain_name]
  injestion_project_id                = data.terraform_remote_state.business_unit_env.outputs.data_domain_ingestion_projects[var.domain_name].project_id
  non_confidential_data_project_id    = data.terraform_remote_state.business_unit_env.outputs.data_domain_non_confidential_projects[var.domain_name].project_id
  app_infra_artifacts_project_id      = data.terraform_remote_state.business_unit_shared.outputs.app_infra_artifacts_project_id
  restricted_network_name             = data.terraform_remote_state.network_env.outputs.restricted_network_name
  restricted_subnets_names            = data.terraform_remote_state.network_env.outputs.restricted_subnets_names
  restricted_host_project_id          = data.terraform_remote_state.network_env.outputs.restricted_host_project_id
  data_governance_project_id          = data.terraform_remote_state.business_unit_shared.outputs.data_governance_project_id
  dlp_deidentify_template_id          = data.terraform_remote_state.data_governance.outputs.dlp_deidentify_template_id
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

data "terraform_remote_state" "env" {
  backend = "gcs"

  config = {
    bucket = local.projects_backend_bucket
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

data "terraform_remote_state" "business_unit_env" {
  backend = "gcs"

  config = {
    bucket = local.projects_backend_bucket
    prefix = "terraform/projects/${var.business_unit}/${var.env}"
  }
}

data "terraform_remote_state" "network_env" {
  backend = "gcs"

  config = {
    bucket = var.remote_state_bucket
    prefix = "terraform/networks/${var.env}"
  }
}

data "terraform_remote_state" "data_governance" {
  backend = "gcs"

  config = {
    bucket = var.data_governance_state_bucket
    prefix = "terraform/production"
  }
}
