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
  secret_admin_ids = [
    google_secret_manager_secret.gh_secrets.secret_id,
    google_secret_manager_secret.kms_wrapper.secret_id,
    google_secret_manager_secret.dlp_kms_wrapper.secret_id,
    google_secret_manager_secret.tag_engine_oauth_client_id.secret_id,
  ]
}

resource "google_secret_manager_secret_iam_member" "secret_admin" {
  for_each = toset(local.secret_admin_ids)
  project  = module.org_secrets.project_id
  role     = "roles/secretmanager.admin"
  member   = "serviceAccount:${local.projects_step_terraform_service_account_email}"

  secret_id = each.key
}

resource "google_project_iam_member" "kms_sa_base" {

  project = module.common_kms.project_id
  role    = "roles/cloudkms.admin"
  member  = "serviceAccount:${local.projects_step_terraform_service_account_email}"
}

resource "google_project_service_identity" "secret_manager_agent_sa" {
  provider = google-beta

  project = module.org_secrets.project_id
  service = "secretmanager.googleapis.com"
}

resource "time_sleep" "wait_for_secret_manager_agent" {
  create_duration = "10s"

  depends_on = [google_project_service_identity.secret_manager_agent_sa]
}

resource "google_kms_crypto_key_iam_member" "encrypt_decrypt" {
  for_each = google_kms_crypto_key.github_kms_keys

  crypto_key_id = each.value.id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = "serviceAccount:${google_project_service_identity.secret_manager_agent_sa.email}"
}

resource "google_kms_crypto_key_iam_member" "kms_wrapper_iam" {
  for_each = google_kms_crypto_key.kms_wrapper_kms_keys

  crypto_key_id = each.value.id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = "serviceAccount:${google_project_service_identity.secret_manager_agent_sa.email}"
}

resource "google_kms_crypto_key_iam_member" "kms_tag_engine_oauth_iam" {
  for_each = google_kms_crypto_key.tag_engine_oauth_client_id_kms_keys

  crypto_key_id = each.value.id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = "serviceAccount:${google_project_service_identity.secret_manager_agent_sa.email}"
}

resource "google_storage_bucket_iam_member" "logging" {
  bucket     = "bkt-${module.org_audit_logs.project_id}-org-logs-${random_string.suffix.result}"
  role       = "roles/storage.admin"
  member     = "serviceAccount:${local.projects_step_terraform_service_account_email}"
  depends_on = [module.logs_export]
}
