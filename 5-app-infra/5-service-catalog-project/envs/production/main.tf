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
  kms_keys = { for key in local.service_catalog_kms_keys : (split("/", key.key_ring)[3]) => key }
}

module "service_catalog_artifacts" {
  source = "../../modules/service_catalog"

  project_id = local.project_id
  region     = var.region

  project_service_account_email = local.service_catalog.sa

  common_secrets_project_id = local.common_secrets_project_id
  service_catalog_kms_keys  = local.kms_keys

  gh_token_secret        = local.gh_token_secret
  gh_app_installation_id = local.gh_app_installation_id
  solutions_repository   = local.solutions_repository

  bucket_roles = {
    "roles/storage.objectViewer" = flatten([for sa in local.data_domain_projects_sa : ["serviceAccount:${sa}"]])
  }
}
