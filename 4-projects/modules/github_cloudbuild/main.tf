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

resource "github_repository" "infra" {
  for_each      = var.create_repositories ? var.gh_common_project_repos.project_repos : {}
  name          = each.value
  description   = "Repository for ${each.key}"
  visibility    = "private"
  has_issues    = true
  has_wiki      = true
  has_downloads = true

  topics = ["terraform", "github"]

  auto_init = true
}

resource "github_actions_secret" "secrets" {
  for_each = local.gh_secrets

  repository      = each.value.repository
  secret_name     = each.value.secret_name
  plaintext_value = each.value.plaintext_value

  depends_on = [github_repository.infra]
}

resource "google_cloudbuildv2_connection" "github" {
  project  = var.app_infra_github_actions_project_id
  location = var.default_region
  name     = "terraform-app-infra-pipeline"

  github_config {
    app_installation_id = var.github_app_installation_id
    authorizer_credential {
      oauth_token_secret_version = data.google_secret_manager_secret_version.gh_infra_token.id
    }
  }

  depends_on = [
    google_secret_manager_secret_iam_member.secrets
  ]
}

resource "google_cloudbuildv2_repository" "github" {
  for_each          = github_repository.infra
  project           = data.google_project.project.project_id
  location          = var.default_region
  name              = each.value.name
  parent_connection = google_cloudbuildv2_connection.github.id
  remote_uri        = each.value.http_clone_url
}

module "github_tf_workspace" {
  source   = "../tf_cloudbuild_workspace"
  for_each = github_repository.infra

  project_id       = var.app_infra_github_actions_project_id
  location         = var.default_region
  trigger_location = var.default_region

  # using bucket custom names for compliance with bucket naming conventions
  create_state_bucket       = true
  create_state_bucket_name  = "${var.bucket_prefix}-${var.app_infra_github_actions_project_id}-${each.key}-state"
  log_bucket_name           = "${var.bucket_prefix}-${var.app_infra_github_actions_project_id}-${each.key}-logs"
  artifacts_bucket_name     = "${var.bucket_prefix}-${var.app_infra_github_actions_project_id}-${each.key}-artifacts"
  cloudbuild_plan_filename  = "cloudbuild-connection-tf-plan.yaml"
  cloudbuild_apply_filename = "cloudbuild-connection-tf-apply.yaml"
  enable_worker_pool        = false
  tf_repo_uri               = each.value.html_url
  tf_repo_type              = "CLOUDBUILDv2"
  create_cloudbuild_sa      = true
  create_cloudbuild_sa_name = "sa-tf-cb-${each.key}"
  diff_sa_project           = true
  buckets_force_destroy     = true
  cloudbuildv2_repo_id      = google_cloudbuildv2_repository.github[each.key].id
  substitutions = {
    "_BILLING_ID"                   = var.billing_account
    "_DOCKER_TAG_VERSION_TERRAFORM" = var.terraform_docker_tag_version
    "_DOCKER_TAG_VERSION_GCLOUD"    = var.gcloud_docker_tag_version
  }

  tf_apply_branches = ["development", "nonproduction", "production"]

  depends_on = [
    github_repository.infra,
    google_cloudbuildv2_repository.github
  ]
}
