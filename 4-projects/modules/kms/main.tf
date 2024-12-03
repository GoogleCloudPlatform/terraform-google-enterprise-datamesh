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
  key_name = var.project_id != null && var.enable_cloudbuild_deploy ? replace(var.name, "/-[0-9a-z]+$/", "") : var.name
}

resource "google_kms_crypto_key" "kms_key_ephemeral" {
  count           = var.prevent_destroy ? 0 : 1
  name            = local.key_name
  key_ring        = var.key_ring
  rotation_period = var.key_rotation_period

  lifecycle {
    prevent_destroy = false
  }
}

resource "google_kms_crypto_key" "kms_key" {
  count           = var.prevent_destroy ? 1 : 0
  name            = local.key_name
  key_ring        = var.key_ring
  rotation_period = var.key_rotation_period

  lifecycle {
    prevent_destroy = true
  }
}

// Add crypto key viewer role to kms environment project
resource "google_project_iam_member" "kms_viewer" {
  count   = var.enable_cloudbuild_deploy ? 1 : 0
  project = var.project_id
  role    = "roles/cloudkms.viewer"
  member  = "serviceAccount:${var.app_infra_pipeline_service_account}"
}

resource "google_project_iam_member" "additional_kms_viewer" {
  for_each = toset(var.additional_kms_viewer_members)
  project  = var.project_id
  role     = "roles/cloudkms.viewer"
  member   = each.value
}

// Add crypto key encrypter role to kms environment project

resource "google_kms_crypto_key_iam_member" "kms_encrypt_decrypt_ephemeral" {
  count = var.prevent_destroy ? 0 : length(var.encrypter_decrypters)

  crypto_key_id = google_kms_crypto_key.kms_key_ephemeral[0].id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = var.encrypter_decrypters[count.index]
}

resource "google_kms_crypto_key_iam_member" "kms_encrypt_decrypt" {
  count = var.prevent_destroy ? length(var.encrypter_decrypters) : 0

  crypto_key_id = google_kms_crypto_key.kms_key[0].id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = var.encrypter_decrypters[count.index]
}
