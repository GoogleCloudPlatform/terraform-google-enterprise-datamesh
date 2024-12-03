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

###############################################
# Create Artifact Registry Repositories
###############################################

resource "google_artifact_registry_repository" "repository" {
  for_each = { for repo in local.registry_repository_types : repo.id => repo }
  provider = google-beta

  project       = var.project_id
  location      = var.default_region
  repository_id = each.value.id
  format        = each.value.format
  description   = each.value.description

  kms_key_name = local.app_infra_artifacts_kms_keys[var.default_region].id

  dynamic "cleanup_policies" {
    for_each = var.artifacts_repository_cleanup_policies != null ? [1] : []
    content {
      id     = cleanup_policies.value.id
      action = cleanup_policies.value.action

      dynamic "condition" {
        for_each = cleanup_policies.value.condition != null ? [cleanup_policies.value.condition] : []
        content {
          tag_state             = condition.value[0].tag_state
          tag_prefixes          = condition.value[0].tag_prefixes
          package_name_prefixes = condition.value[0].package_name_prefixes
          older_than            = condition.value[0].older_than
        }
      }

      dynamic "most_recent_versions" {
        for_each = cleanup_policies.value.most_recent_versions != null ? [cleanup_policies.value.most_recent_versions] : []
        content {
          package_name_prefixes = most_recent_versions.value[0].package_name_prefixes
          keep_count            = most_recent_versions.value[0].keep_count
        }
      }
    }
  }
}

###########
# Storage
###########

resource "random_id" "suffix" {
  byte_length = 2
}

module "gcs_templates_bucket" {

  source  = "terraform-google-modules/cloud-storage/google//modules/simple_bucket"
  version = "~> 6.0"

  project_id         = var.project_id
  location           = var.default_region
  name               = "${var.bucket_name_prefix}-${var.project_id}-${var.default_region}-tpl-${random_id.suffix.hex}"
  bucket_policy_only = true

  encryption = {
    default_kms_key_name = local.app_infra_artifacts_kms_keys[var.default_region].id
  }

  labels = {
    bucket = "flex-templates"
  }
}

################################
# Cloudbuild 
################################

resource "google_cloudbuildv2_connection" "github_artifact_registry" {
  project  = var.project_id
  location = var.default_region
  name     = "terraform-artifact-build-pipeline"

  github_config {
    app_installation_id = var.github_app_installation_id
    authorizer_credential {
      oauth_token_secret_version = data.google_secret_manager_secret_version.gh_infra_token.id
    }
  }
}

resource "google_cloudbuildv2_repository" "artifact_repo" {

  project           = var.project_id
  location          = var.default_region
  name              = local.github_repository_artifact_repo["name"]
  parent_connection = google_cloudbuildv2_connection.github_artifact_registry.id
  remote_uri        = local.github_repository_artifact_repo["http_clone_url"]
}

resource "google_cloudbuild_trigger" "triggers_docker_pull_requests" {
  for_each = toset(["development", "nonproduction", "production"])

  project     = var.project_id
  location    = var.default_region
  name        = "artifact-repo-docker-pull-request-${each.key}"
  description = "artifact-repo-${local.github_repository_artifact_repo["name"]}-pull-request"

  repository_event_config {
    repository = google_cloudbuildv2_repository.artifact_repo.id

    pull_request {
      branch = "^${each.key}$"
    }
  }

  included_files = [
    "docker/**",
  ]
  substitutions = {
    "_BILLING_ID"                     = local.billing_account
    "_REGION"                         = var.default_region
    "_DOCKER_ARTIFACT_FLEX_REPO_NAME" = google_artifact_registry_repository.repository["flex-templates"].name
    "_DOCKER_ARTIFACT_CDMC_REPO_NAME" = google_artifact_registry_repository.repository["cdmc"].name
    "_PYTHON_ARTIFACT_REPO_NAME"      = google_artifact_registry_repository.repository["python-modules"].name
    "_TEMPLATE_BUCKET_NAME"           = "gs://${module.gcs_templates_bucket.name}"
    "_SECRET_MANAGER_VERSION"         = data.google_secret_manager_secret_version.gh_infra_token.name
    "_TAG_ENGINE_SECRET_VERSION"      = data.google_secret_manager_secret_version.tag_engine_oauth_client_id.name
    "_REPO_URL"                       = replace(local.github_repository_artifact_repo["html_url"], "https://", "")
    "_ENVIRONMENT"                    = each.key
  }

  filename        = "cloudbuild-docker-pull-request.yaml"
  service_account = local.app_infra_cloudbuild_service_account_id
}

resource "google_cloudbuild_trigger" "triggers_docker_push" {
  for_each = toset(["development", "nonproduction", "production"])

  project     = var.project_id
  location    = var.default_region
  name        = "artifact-repo-docker-merge-${each.key}"
  description = "artifact-repo ${local.github_repository_artifact_repo["name"]} merge"

  repository_event_config {
    repository = google_cloudbuildv2_repository.artifact_repo.id

    push {
      branch       = "^${each.key}$"
      invert_regex = false
    }
  }

  included_files = [
    "docker/**",
  ]
  substitutions = {
    "_BILLING_ID"                     = local.billing_account
    "_REGION"                         = var.default_region
    "_DOCKER_ARTIFACT_FLEX_REPO_NAME" = google_artifact_registry_repository.repository["flex-templates"].name
    "_DOCKER_ARTIFACT_CDMC_REPO_NAME" = google_artifact_registry_repository.repository["cdmc"].name
    "_PYTHON_ARTIFACT_REPO_NAME"      = google_artifact_registry_repository.repository["python-modules"].name
    "_TEMPLATE_BUCKET_NAME"           = "gs://${module.gcs_templates_bucket.name}"
    "_SECRET_MANAGER_VERSION"         = data.google_secret_manager_secret_version.gh_infra_token.name
    "_TAG_ENGINE_SECRET_VERSION"      = data.google_secret_manager_secret_version.tag_engine_oauth_client_id.name
    "_REPO_URL"                       = replace(local.github_repository_artifact_repo["html_url"], "https://", "")
    "_ENVIRONMENT"                    = each.key
  }


  filename        = "cloudbuild-docker-push.yaml"
  service_account = local.app_infra_cloudbuild_service_account_id
}

resource "google_cloudbuild_trigger" "triggers_python_publish" {
  project     = var.project_id
  location    = var.default_region
  name        = "artifact-repo-python-publish"
  description = "artifact-repo ${local.github_repository_artifact_repo["name"]} merge"

  repository_event_config {
    repository = google_cloudbuildv2_repository.artifact_repo.id
    push {
      branch       = "^development$"
      invert_regex = false
    }
  }

  included_files = [
    "python/**",
  ]

  substitutions = {
    "_BILLING_ID"                   = local.billing_account
    "_ARTIFACT_REPO_NAME"           = google_artifact_registry_repository.repository["python-modules"].name
    "_APACHE_BEAM_VERSION"          = "2.54.0"
    "_DEFAULT_REGION"               = var.default_region
    "_REPOSITORY_ID"                = "python-modules"
    "_PYTHON_VERSION"               = "311"
    "_IMPLEMENTATION"               = "cp"
    "_APPLICATION_BINARY_INTERFACE" = "cp311"
    "_PLATFORM"                     = "manylinux_2_17_x86_64"
    "_ENVIRONMENT"                  = "development"
  }

  filename        = "cloudbuild-python-push.yaml"
  service_account = local.app_infra_cloudbuild_service_account_id
}
