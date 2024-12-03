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
  project_id                = data.terraform_remote_state.business_unit_shared.outputs.service_catalog.project_id
  common_secrets_project_id = data.terraform_remote_state.org.outputs.org_secrets_project_id
  gh_token_secret           = data.terraform_remote_state.org.outputs.gh_token_secret
  gh_app_installation_id    = data.terraform_remote_state.business_unit_shared.outputs.github_app_installation_id
  service_catalog           = data.terraform_remote_state.business_unit_shared.outputs.service_catalog
  service_catalog_kms_keys  = data.terraform_remote_state.business_unit_shared.outputs.service_catalog_project_kms_keys
  solutions_repository      = data.terraform_remote_state.business_unit_shared.outputs.github_repository_artifact_repo["service-catalog"]
  data_domain_projects_sa = flatten([for domain in var.data_domains : [
    data.terraform_remote_state.business_unit_env_dev.outputs.data_domain_ingestion_projects[domain].sa,
    data.terraform_remote_state.business_unit_env_dev.outputs.data_domain_non_confidential_projects[domain].sa,
  ]])
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
