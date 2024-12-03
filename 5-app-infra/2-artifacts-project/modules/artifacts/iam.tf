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

  dataflow_controller_sas = merge(
    {
      for k, v in local.dataflow_controller_sa_ingestion_dev : "${k}-dev" => v
    },
    {
      for k, v in local.dataflow_controller_sa_confidential_dev : "${k}-confidential-dev" => v
    },
    {
      for k, v in local.dataflow_controller_sa_ingestion_nonp : "${k}-nonp" => v
    },
    {
      for k, v in local.dataflow_controller_sa_confidential_nonp : "${k}-confidential-nonp" => v
    },
    {
      for k, v in local.dataflow_controller_sa_ingestion_prod : "${k}-prod" => v
    },
    {
      for k, v in local.dataflow_controller_sa_confidential_prod : "${k}-confidential-prod" => v
    }
  )

  cloudrun_sas = [
    local.cloudrun_service_agent_data_governance
  ]
}

resource "google_kms_crypto_key_iam_member" "secret_manager_artifact_registry" {
  for_each = { for kms in local.kms_keys : "${kms.region}-${kms.key_name}-${kms.sa}" => kms }

  crypto_key_id = each.value.key_id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = "serviceAccount:${each.value.sa}"
}

resource "google_artifact_registry_repository_iam_member" "artifact_registry_python_writer" {

  project    = var.project_id
  location   = var.default_region
  repository = google_artifact_registry_repository.repository["python-modules"].name
  role       = "roles/artifactregistry.writer"
  member     = "serviceAccount:${data.google_service_account.cloudbuild_sa.email}"
}

resource "google_artifact_registry_repository_iam_member" "artifact_registry_docker_writer" {
  for_each   = toset([for registry in local.registry_repository_types : registry.id if registry.format == "DOCKER"])
  project    = var.project_id
  location   = var.default_region
  repository = google_artifact_registry_repository.repository[each.key].name
  role       = "roles/artifactregistry.writer"
  member     = "serviceAccount:${data.google_service_account.cloudbuild_sa.email}"
}

resource "google_storage_bucket_iam_member" "artifact_registry_bucket_writer" {
  bucket = module.gcs_templates_bucket.name
  role   = "roles/storage.objectUser"
  member = "serviceAccount:${data.google_service_account.cloudbuild_sa.email}"
}

resource "google_storage_bucket_iam_member" "artifact_registry_bucket_viewer" {
  for_each = { for k, v in local.data_domain_ingestion_projects : k => v.sa }
  bucket   = module.gcs_templates_bucket.name
  role     = "roles/storage.objectViewer"
  member   = "serviceAccount:${each.value}"
}

resource "google_artifact_registry_repository_iam_member" "artifact_registry_dataflowdocker_reader" {
  for_each   = local.dataflow_controller_sas
  project    = var.project_id
  location   = var.default_region
  repository = google_artifact_registry_repository.repository["flex-templates"].name
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:${each.value}"
}

resource "google_artifact_registry_repository_iam_member" "artifact_registry_cloudrun_reader" {
  for_each   = toset(local.cloudrun_sas)
  project    = var.project_id
  location   = var.default_region
  repository = google_artifact_registry_repository.repository["cdmc"].name
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:${each.key}"
}
resource "google_artifact_registry_repository_iam_member" "artifact_registry_python_reader" {
  for_each   = local.dataflow_controller_sas
  project    = var.project_id
  location   = var.default_region
  repository = google_artifact_registry_repository.repository["python-modules"].name
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:${each.value}"
}
