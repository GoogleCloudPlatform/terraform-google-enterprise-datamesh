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


// Create two keyrings in two geographic regions

module "kms_keyrings" {
  source   = "terraform-google-modules/kms/google"
  for_each = toset(var.keyring_regions)
  version  = "~> 2.1"

  project_id      = module.common_kms.project_id
  keyring         = var.keyring_name
  location        = each.key
  prevent_destroy = "false"

  depends_on = [module.common_kms]
}


resource "google_kms_crypto_key" "github_kms_keys" {
  for_each = {
    for region, key in module.kms_keyrings : region => key.keyring
  }
  name            = "github-secrets-kms"
  key_ring        = each.value
  rotation_period = var.key_rotation_period

  lifecycle {
    prevent_destroy = false
  }
}

resource "google_kms_crypto_key" "kms_wrapper_kms_keys" {
  for_each = {
    for region, key in module.kms_keyrings : region => key.keyring
  }
  name            = "kms-wrapper"
  key_ring        = each.value
  rotation_period = var.key_rotation_period
  lifecycle {
    prevent_destroy = false
  }
}

resource "google_kms_crypto_key" "tag_engine_oauth_client_id_kms_keys" {
  for_each = {
    for region, key in module.kms_keyrings : region => key.keyring
  }
  name            = "tag-engine-oauth-client-id"
  key_ring        = each.value
  rotation_period = var.key_rotation_period
  lifecycle {
    prevent_destroy = false
  }
}
