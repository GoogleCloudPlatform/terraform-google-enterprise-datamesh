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

########################################
# KMS
########################################

locals {
  shared_key_sa_map = flatten([
    for key_ring in var.shared_kms_key_ring : [
      {
        key_ring = key_ring
        location = split("/", key_ring)[3]
        key      = "project_key_common"
        type     = "project"
        encrypter_decrypters = [
          "serviceAccount:service-${module.data_governance_project.project_number}@gs-project-accounts.iam.gserviceaccount.com",
          "serviceAccount:service-${module.data_governance_project.project_number}@gcp-sa-pubsub.iam.gserviceaccount.com",
        ]
      },
      {
        key_ring = key_ring
        location = split("/", key_ring)[3]
        key      = "deidenfication_key_common"
        type     = "kek"
        encrypter_decrypters = [
          "serviceAccount:${var.terraform_service_account}",
          "serviceAccount:service-${module.data_governance_project.project_number}@dlp-api.iam.gserviceaccount.com"
        ]
      },
      {
        key_ring = key_ring
        location = split("/", key_ring)[3]
        key      = "data_quality_bigquery_common"
        type     = "bq_encrypt"
        encrypter_decrypters = [
          "serviceAccount:${data.google_bigquery_default_service_account.bq_sa.email}"
        ]
      },
      {
        key_ring = key_ring
        location = split("/", key_ring)[3]
        key      = "tag_history_bigquery_common"
        type     = "bq_encrypt"
        encrypter_decrypters = [
          "serviceAccount:${data.google_bigquery_default_service_account.bq_sa.email}"
        ]
      },
      {
        key_ring = key_ring
        location = split("/", key_ring)[3]
        key      = "firestore_common"
        type     = "fs_encrypt"
        encrypter_decrypters = [
          "serviceAccount:${google_project_service_identity.firestore.email}"
        ]
      }
    ]
  ])
}

################################
# KMS
################################
module "data_governance_keys" {
  source   = "../kms"
  for_each = { for key_ring in local.shared_key_sa_map : "${key_ring.key}-${key_ring.location}" => key_ring }

  name                = each.value.key
  key_ring            = each.value.key_ring
  key_rotation_period = var.key_rotation_period
  prevent_destroy     = var.kms_key_prevent_destroy

  encrypter_decrypters = each.value.encrypter_decrypters

  depends_on = [time_sleep.wait_for_service_identity]
}
