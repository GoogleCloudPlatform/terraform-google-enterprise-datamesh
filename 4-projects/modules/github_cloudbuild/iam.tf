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

resource "google_storage_bucket_iam_member" "tf_state" {
  for_each = { for k, v in module.github_tf_workspace : k => v.cloudbuild_sa_email }

  bucket = var.remote_project_state_bucket
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${each.value}"
}
// Required by gcloud beta terraform vet
resource "google_organization_iam_member" "browser" {
  # for_each = toset(module.github_tf_workspace[0].cloudbuild_sa)
  for_each = { for k, v in module.github_tf_workspace : k => v.cloudbuild_sa_email }

  org_id = var.org_id
  role   = "roles/browser"
  member = "serviceAccount:${each.value}"
}

resource "google_secret_manager_secret_iam_member" "secrets" {
  project   = var.secrets_project_id
  secret_id = data.google_secret_manager_secret.gh_infra_token.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:service-${data.google_project.project.number}@gcp-sa-cloudbuild.iam.gserviceaccount.com"
}
