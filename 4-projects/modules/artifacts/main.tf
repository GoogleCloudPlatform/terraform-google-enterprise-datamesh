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
  artifact_tf_sa_roles = [
    "roles/artifactregistry.admin",
    "roles/cloudbuild.builds.editor",
    "roles/cloudbuild.connectionAdmin",
    "roles/iam.serviceAccountAdmin",
    "roles/secretmanager.admin",
    "roles/storage.admin",
  ]

  common_secrets = {
    "PROJECT_ID" : module.app_infra_artifacts[0].project_id,
    "TF_VAR_gh_token" : var.github_app_infra_token
  }

  sa_secrets = [
    for k, v in var.gh_artifact_repos.artifact_project_repos : {
      repository      = var.create_github_artifact_repositories ? github_repository.artifact_repo[k].name : v
      secret_name     = "SERVICE_ACCOUNT_EMAIL"
      plaintext_value = google_project_service_identity.artifact_registry_cloudbuild_sa[0].email
      config          = k
    }
  ]

  secrets_list = flatten([
    for k, v in var.gh_artifact_repos.artifact_project_repos : [
      for secret, plaintext in local.common_secrets : {
        config          = k
        secret_name     = secret
        plaintext_value = plaintext
        repository      = var.create_github_artifact_repositories ? github_repository.artifact_repo[k].name : v
      }
    ]
  ])

  gh_secrets = {
    for v in concat(local.sa_secrets, local.secrets_list) : "${v.config}.${v.secret_name}" => v
  }

  secret_ids = [
    data.google_secret_manager_secret.gh_infra_token.secret_id,
    data.google_secret_manager_secret.tag_engine_token.secret_id
  ]
}

######################
# Data sources
######################

data "google_secret_manager_secret" "gh_infra_token" {
  project   = var.secrets_project_id
  secret_id = var.gh_token_secret
}

data "google_secret_manager_secret" "tag_engine_token" {
  project   = var.secrets_project_id
  secret_id = var.tag_engine_oauth_secret
}

data "github_repository" "artifact_repo" {
  for_each = var.gh_artifact_repos.artifact_project_repos
  name     = each.value

  depends_on = [github_repository.artifact_repo]
}

######################
# Project creation
######################

module "app_infra_artifacts" {
  source = "../../modules/single_project"
  count  = var.gh_artifact_repos != null ? 1 : 0

  org_id                   = var.org_id
  billing_account          = var.billing_account
  folder_id                = var.folder_id
  environment              = "common"
  project_budget           = var.project_budget
  project_prefix           = var.project_prefix
  enable_cloudbuild_deploy = true

  activate_apis = [
    "cloudresourcemanager.googleapis.com",
    "compute.googleapis.com",
    "storage-api.googleapis.com",
    "serviceusage.googleapis.com",
    "iam.googleapis.com",
    "cloudbilling.googleapis.com",
    "artifactregistry.googleapis.com",
    "cloudbuild.googleapis.com"
  ]

  # Metadata
  project_suffix    = var.project_suffix
  application_name  = var.application_name
  billing_code      = var.billing_code
  primary_contact   = var.primary_contact
  secondary_contact = var.secondary_contact
  business_code     = var.business_code
}

###################
# Github
###################

resource "github_repository" "artifact_repo" {
  for_each = var.create_github_artifact_repositories ? var.gh_artifact_repos.artifact_project_repos : {}
  provider = github

  name          = each.value
  description   = "Repository for ${each.key}"
  visibility    = "private"
  has_issues    = true
  has_wiki      = true
  has_downloads = true

  topics = ["github", "docker", "python"]

  auto_init = true
}

resource "github_actions_secret" "secrets" {
  for_each = local.gh_secrets
  provider = github

  repository      = each.value.repository
  secret_name     = each.value.secret_name
  plaintext_value = each.value.plaintext_value

  depends_on = [github_repository.artifact_repo]
}

# ########
# # IAM
# ########

resource "google_project_iam_member" "artifact_tf_sa_roles" {
  for_each = toset(local.artifact_tf_sa_roles)
  project  = module.app_infra_artifacts[0].project_id
  role     = each.key
  member   = "serviceAccount:${var.app_infra_pipeline_service_accounts["artifacts"]}"
}
resource "google_project_service_identity" "artifact_registry_cloudbuild_sa" {
  count = var.gh_common_project_repos != null ? 1 : 0

  provider = google-beta
  project  = module.app_infra_artifacts[0].project_id
  service  = "cloudbuild.googleapis.com"
}

resource "google_project_service_identity" "artifact_registry_service_identity" {
  count = var.gh_common_project_repos != null ? 1 : 0

  provider = google-beta
  project  = module.app_infra_artifacts[0].project_id
  service  = "artifactregistry.googleapis.com"
}

resource "google_project_service_identity" "storage_service_identity" {
  count = var.gh_common_project_repos != null ? 1 : 0

  provider = google-beta
  project  = module.app_infra_artifacts[0].project_id
  service  = "storage.googleapis.com"
}
resource "google_project_iam_member" "cloud_build_builder" {
  count = var.gh_common_project_repos != null ? 1 : 0

  project = module.app_infra_artifacts[0].project_id
  role    = "roles/cloudbuild.builds.builder"
  member  = "serviceAccount:${google_project_service_identity.artifact_registry_cloudbuild_sa[0].email}"
}

resource "google_service_account_iam_member" "artifact_registry_cloudbuild_sa" {
  count = var.gh_common_project_repos != null ? 1 : 0

  service_account_id = google_service_account.cloudbuild_service_account[0].id
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:${var.app_infra_pipeline_service_accounts["artifacts"]}"
}

resource "google_secret_manager_secret_iam_member" "artifacts" {
  for_each  = toset(local.secret_ids)
  project   = var.secrets_project_id
  secret_id = each.key
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${var.app_infra_pipeline_service_accounts["artifacts"]}"
}

resource "google_secret_manager_secret_iam_member" "cloudbuild" {
  for_each  = toset(local.secret_ids)
  project   = var.secrets_project_id
  secret_id = each.key
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.cloudbuild_service_account[0].email}"
}

resource "google_secret_manager_secret_iam_member" "cloudbuild_agent" {
  for_each  = toset(local.secret_ids)
  project   = var.secrets_project_id
  secret_id = each.key
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:service-${module.app_infra_artifacts[0].project_number}@gcp-sa-cloudbuild.iam.gserviceaccount.com"
}

resource "google_secret_manager_secret_iam_member" "secrets_viewer" {
  for_each  = toset(local.secret_ids)
  project   = var.secrets_project_id
  secret_id = each.key
  role      = "roles/secretmanager.viewer"
  member    = "serviceAccount:${var.app_infra_pipeline_service_accounts["artifacts"]}"
}

# ################################
# Cloudbuild
# ################################

resource "google_service_account" "cloudbuild_service_account" {
  count = var.gh_artifact_repos != null ? 1 : 0

  project      = module.app_infra_artifacts[0].project_id
  account_id   = "cloudbuild-artifacts"
  display_name = "Cloudbuild service account"
}

resource "google_project_iam_member" "act_as" {
  count = var.gh_artifact_repos != null ? 1 : 0

  project = module.app_infra_artifacts[0].project_id
  role    = "roles/iam.serviceAccountUser"
  member  = "serviceAccount:${google_service_account.cloudbuild_service_account[0].email}"
}

resource "google_project_iam_member" "logs_writer" {
  count = var.gh_artifact_repos != null ? 1 : 0

  project = module.app_infra_artifacts[0].project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.cloudbuild_service_account[0].email}"
}
