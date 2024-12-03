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
  keyrings = { for key_ring in var.shared_kms_key_ring : (split("/", key_ring)[3]) => key_ring if var.gh_artifact_repos != null }
  service_identities_apis = var.gh_artifact_repos != null ? [
    "artifactregistry.googleapis.com",
    "storage.googleapis.com",
  ] : []
}

resource "google_project_service_identity" "artifacts" {
  for_each = toset(local.service_identities_apis)
  provider = google-beta

  project = module.app_infra_artifacts[0].project_id
  service = each.value
}

resource "time_sleep" "wait_for_service_identity" {
  create_duration = "10s"

  depends_on = [google_project_service_identity.artifacts]
}


module "project_keys" {
  source   = "../kms"
  for_each = local.keyrings

  name                     = module.app_infra_artifacts[0].project_id
  key_ring                 = each.value
  key_rotation_period      = var.key_rotation_period
  prevent_destroy          = var.kms_key_prevent_destroy
  enable_cloudbuild_deploy = true
  project_id               = module.app_infra_artifacts[0].project_id

  app_infra_pipeline_service_account = var.app_infra_pipeline_service_accounts["artifacts"]

  encrypter_decrypters = [
    "serviceAccount:service-${module.app_infra_artifacts[0].project_number}@gcp-sa-artifactregistry.iam.gserviceaccount.com",
    "serviceAccount:service-${module.app_infra_artifacts[0].project_number}@gs-project-accounts.iam.gserviceaccount.com",
  ]

  depends_on = [time_sleep.wait_for_service_identity]
}
