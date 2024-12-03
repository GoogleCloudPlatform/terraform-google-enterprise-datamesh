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

################################
# Cloudbuild 
################################

resource "google_cloudbuildv2_connection" "github" {
  project  = var.project_id
  location = var.region
  name     = "terraform-app-infra-pipeline"

  github_config {
    app_installation_id = var.gh_app_installation_id
    authorizer_credential {
      oauth_token_secret_version = data.google_secret_manager_secret_version.gh_infra_token.id
    }
  }
}

resource "google_cloudbuildv2_repository" "github" {
  project           = var.project_id
  location          = var.region
  name              = var.solutions_repository.name
  parent_connection = google_cloudbuildv2_connection.github.id
  remote_uri        = var.solutions_repository.http_clone_url
}

resource "google_cloudbuild_trigger" "solutions" {
  name     = "zip-service-catalog-solutions"
  project  = var.project_id
  location = var.region

  service_account = data.google_service_account.project_sa.id

  repository_event_config {
    repository = google_cloudbuildv2_repository.github.id
    push {
      branch       = "^main$"
      invert_regex = false
    }
  }
  build {
    step {
      id         = "unshallow"
      name       = "gcr.io/cloud-builders/git"
      secret_env = ["token"]
      entrypoint = "/bin/bash"
      args = [
        "-c",
        "git fetch --unshallow https://$token@${split("https://", var.solutions_repository.http_clone_url)[1]}"
      ]
    }
    available_secrets {
      secret_manager {
        env          = "token"
        version_name = data.google_secret_manager_secret_version.gh_infra_token.id
      }
    }
    step {
      id         = "find-folders-affected-in-push"
      name       = "gcr.io/cloud-builders/git"
      entrypoint = "/bin/bash"
      args = [
        "-c",
        <<-EOT
        changed_files=$(git diff-tree --name-only $COMMIT_SHA --no-commit-id -r)
        changed_folders=$(echo "$changed_files" | xargs -n1 dirname | sort | uniq )

        for folder in $changed_folders; do
          echo "Found change in folder: $folder"
          (echo "cd $folder" && cd $folder && find . -type f -name '*.tf' -exec tar -czvf "/workspace/$(basename $folder).tar.gz" {} +)
        done
      EOT
      ]
    }
    step {
      id   = "push-to-bucket"
      name = "gcr.io/cloud-builders/gsutil"
      args = ["cp", "/workspace/*.tar.gz", "gs://${google_storage_bucket.solutions_bucket.name}/modules/"]
    }

    logs_bucket = "gs://${google_storage_bucket.log_bucket.name}"
  }
}
