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

module "artifacts" {
  source = "../../modules/artifacts"

  org_id          = local.org_id
  folder_id       = local.common_folder_name
  billing_account = local.billing_account

  project_suffix    = "artifacts"
  application_name  = "app-infra-artifacts"
  billing_code      = "1234"
  primary_contact   = "example@example.com"
  secondary_contact = "example2@example.com"
  business_code     = "bu4"

  shared_kms_key_ring = local.shared_kms_key_ring

  project_budget = var.project_budget
  project_prefix = local.project_prefix

  create_github_artifact_repositories = var.create_github_artifact_repositories

  gh_artifact_repos       = var.gh_artifact_repos
  gh_token_secret         = local.gh_token_secret
  gh_common_project_repos = var.gh_common_project_repos
  github_app_infra_token  = var.github_app_infra_token

  tag_engine_oauth_secret = local.tag_engine_oauth_client_id_secret

  app_infra_pipeline_service_accounts = module.github_cloudbuild[0].terraform_service_accounts

  secrets_project_id = local.common_secrets_project_id
  #   dlp_kms_wrapper_secret = local.dlp_kms_wrapper_secret_name

  key_rotation_period = var.key_rotation_period

  # Dependencies
  depends_on = [
    module.app_infra_github_cloudbuild_project,
    module.github_cloudbuild
  ]
}
