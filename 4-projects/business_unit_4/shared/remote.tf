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
  org_id                             = data.terraform_remote_state.bootstrap.outputs.common_config.org_id
  billing_account                    = data.terraform_remote_state.bootstrap.outputs.common_config.billing_account
  common_folder_name                 = data.terraform_remote_state.org.outputs.common_folder_name
  project_prefix                     = data.terraform_remote_state.bootstrap.outputs.common_config.project_prefix
  projects_remote_bucket_tfstate     = data.terraform_remote_state.bootstrap.outputs.projects_gcs_bucket_tfstate
  cloud_build_private_worker_pool_id = try(data.terraform_remote_state.bootstrap.outputs.cloud_build_private_worker_pool_id, "")
  cloud_builder_artifact_repo        = try(data.terraform_remote_state.bootstrap.outputs.cloud_builder_artifact_repo, "")
  common_secrets_project_id          = data.terraform_remote_state.org.outputs.org_secrets_project_id
  enable_cloudbuild_deploy           = local.cloud_builder_artifact_repo != ""
  shared_kms_key_ring                = data.terraform_remote_state.org.outputs.key_rings
  shared_kms_project_id              = data.terraform_remote_state.org.outputs.common_kms_project_id
  gh_token_secret                    = data.terraform_remote_state.org.outputs.gh_token_secret
  kms_wrapper_secret_name            = data.terraform_remote_state.org.outputs.kms_wrapper_secret
  dlp_kms_wrapper_secret_name        = data.terraform_remote_state.org.outputs.dlp_kms_wrapper_secret
  tag_engine_oauth_client_id_secret  = data.terraform_remote_state.org.outputs.tag_engine_oauth_client_id_secret
  restricted_host_project_id         = data.terraform_remote_state.network_env.outputs.restricted_host_project_id
  restricted_subnets_self_links      = data.terraform_remote_state.network_env.outputs.restricted_subnets_self_links
  base_host_project_id               = data.terraform_remote_state.network_env.outputs.base_host_project_id
  base_subnets_self_links            = data.terraform_remote_state.network_env.outputs.base_subnets_self_links
  access_context_manager_policy_id   = data.terraform_remote_state.network_env.outputs.access_context_manager_policy_id
  perimeter_name                     = data.terraform_remote_state.network_env.outputs.restricted_service_perimeter_name
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
    prefix = "terraform/networks/envs/shared"
  }
}
