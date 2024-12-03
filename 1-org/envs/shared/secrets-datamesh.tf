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

locals {
  kms_key_map = {
    for key in google_kms_crypto_key.github_kms_keys :
    split("/", key.key_ring)[3] => key.id
  }

  kms_key_wrapper_map = {
    for key in google_kms_crypto_key.kms_wrapper_kms_keys :
    split("/", key.key_ring)[3] => key.id
  }

  tag_engine_oath_key_map = {
    for key in google_kms_crypto_key.tag_engine_oauth_client_id_kms_keys :
    split("/", key.key_ring)[3] => key.id
  }
}

resource "time_sleep" "kms_propagation" {
  create_duration = "30s"

  depends_on = [
    google_kms_crypto_key.github_kms_keys,
    google_kms_crypto_key.kms_wrapper_kms_keys,
    google_kms_crypto_key.tag_engine_oauth_client_id_kms_keys,
    google_kms_crypto_key_iam_member.encrypt_decrypt,
  ]
}


resource "google_secret_manager_secret" "gh_secrets" {
  project   = module.org_secrets.project_id
  secret_id = var.github_app_infra_token_secret_id

  replication {
    user_managed {
      dynamic "replicas" {
        for_each = local.kms_key_map
        content {
          location = replicas.key
          customer_managed_encryption {
            kms_key_name = replicas.value
          }

        }
      }
    }
  }

  depends_on = [time_sleep.kms_propagation]
}

resource "google_secret_manager_secret" "kms_wrapper" {
  project   = module.org_secrets.project_id
  secret_id = var.kms_wrapper_secret_id

  replication {
    user_managed {
      dynamic "replicas" {
        for_each = local.kms_key_wrapper_map
        content {
          location = replicas.key
          customer_managed_encryption {
            kms_key_name = replicas.value
          }

        }
      }
    }
  }

  depends_on = [time_sleep.kms_propagation]
}

resource "google_secret_manager_secret" "dlp_kms_wrapper" {
  project   = module.org_secrets.project_id
  secret_id = "dlp-${var.kms_wrapper_secret_id}"

  replication {
    user_managed {
      dynamic "replicas" {
        for_each = local.kms_key_wrapper_map
        content {
          location = replicas.key
          customer_managed_encryption {
            kms_key_name = replicas.value
          }

        }
      }
    }
  }

  depends_on = [time_sleep.kms_propagation]
}

resource "google_secret_manager_secret" "tag_engine_oauth_client_id" {
  project   = module.org_secrets.project_id
  secret_id = var.tag_engine_oauth_client_id_secret_id

  replication {
    user_managed {
      dynamic "replicas" {
        for_each = local.tag_engine_oath_key_map
        content {
          location = replicas.key
          customer_managed_encryption {
            kms_key_name = replicas.value
          }

        }
      }
    }
  }

  depends_on = [time_sleep.kms_propagation]
}

resource "google_secret_manager_secret_version" "github_secret" {
  secret      = google_secret_manager_secret.gh_secrets.id
  secret_data = var.github_app_infra_token

  depends_on = [time_sleep.kms_propagation]
}

