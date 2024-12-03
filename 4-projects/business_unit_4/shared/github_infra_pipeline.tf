/**
 * Copyright 2021 Google LLC
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

module "app_infra_github_cloudbuild_project" {
  source = "../../modules/single_project"
  count  = var.gh_common_project_repos != null ? 1 : 0

  org_id          = local.org_id
  billing_account = local.billing_account
  folder_id       = local.common_folder_name
  environment     = "common"
  project_budget  = var.project_budget

  activate_apis = [
    "admin.googleapis.com",
    "artifactregistry.googleapis.com",
    "bigquery.googleapis.com",
    "billingbudgets.googleapis.com",
    "cloudbilling.googleapis.com",
    "cloudbuild.googleapis.com",
    "cloudkms.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "datacatalog.googleapis.com",
    "dataflow.googleapis.com",
    "dlp.googleapis.com",
    "compute.googleapis.com",
    "iam.googleapis.com",
    "iamcredentials.googleapis.com",
    "serviceusage.googleapis.com",
  ]

  # Metadata
  project_suffix    = "infra-gh-cb"
  application_name  = "app-github-cloudbuild"
  billing_code      = "1234"
  primary_contact   = "example@example.com"
  secondary_contact = "example2@example.com"
  business_code     = "bu4"
}

module "github_cloudbuild" {
  source = "../../modules/github_cloudbuild"
  count  = var.gh_common_project_repos != null ? 1 : 0

  providers = {
    github = github
  }

  app_infra_github_actions_project_id = module.app_infra_github_cloudbuild_project[0].project_id
  default_region                      = var.default_region
  github_app_infra_token              = var.github_app_infra_token
  secrets_project_id                  = local.common_secrets_project_id
  github_app_installation_id          = var.github_app_installation_id
  gh_token_secret_id                  = local.gh_token_secret
  billing_account                     = local.billing_account
  gh_common_project_repos             = var.gh_common_project_repos
  org_id                              = local.org_id
  remote_project_state_bucket         = var.remote_state_bucket
  create_repositories                 = var.create_repositories
}

resource "google_kms_key_ring_iam_member" "github_cloudbuild_sa" {
  for_each = var.gh_common_project_repos != null ? { for k in flatten([for kms in local.shared_kms_key_ring : [for name, sa in module.github_cloudbuild[0].terraform_service_accounts : { kms = "${kms}-${name}-sa", name = kms, sa = sa }]]) : k.kms => k } : {}

  key_ring_id = each.value.name
  role        = "roles/cloudkms.admin"
  member      = "serviceAccount:${each.value.sa}"
}
