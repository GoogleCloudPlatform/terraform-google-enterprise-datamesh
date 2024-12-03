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

  key_sa_map = flatten([
    for key_ring in local.shared_kms_key_ring : [
      {
        key_ring = key_ring
        location = split("/", key_ring)[3]
        key      = "data_ingestion_key_${var.business_code}_${var.data_domain.name}_${var.env}"
        sa = [
          "serviceAccount:${data.google_storage_project_service_account.gcs_account.email_address}",
          "serviceAccount:service-${module.ingestion_project.project_number}@gcp-sa-pubsub.iam.gserviceaccount.com",
          "serviceAccount:service-${module.ingestion_project.project_number}@dataflow-service-producer-prod.iam.gserviceaccount.com",
          "serviceAccount:service-${module.ingestion_project.project_number}@compute-system.iam.gserviceaccount.com",
          "serviceAccount:bq-${module.nonconfidential_project.project_number}@bigquery-encryption.iam.gserviceaccount.com",
        ]
      },
      {
        key_ring = key_ring
        location = split("/", key_ring)[3]
        key      = "bigquery_key_${var.business_code}_${var.data_domain.name}_${var.env}"
        sa = [
          "serviceAccount:${data.google_bigquery_default_service_account.nonconfidential_bigquery_sa.email}",
          "serviceAccount:${local.data_governance_sa_cloud_function}"
        ]
      },
      {
        key_ring = key_ring
        location = split("/", key_ring)[3]
        key      = "reidentification_key_${var.business_code}_${var.data_domain.name}_${var.env}"
        sa = [
          "serviceAccount:${data.google_storage_project_service_account.confidential_gcs_account.email_address}",
          "serviceAccount:service-${module.confidential_project.project_number}@dataflow-service-producer-prod.iam.gserviceaccount.com",
          "serviceAccount:service-${module.confidential_project.project_number}@compute-system.iam.gserviceaccount.com",
        ]
      },
      {
        key_ring = key_ring
        location = split("/", key_ring)[3]
        key      = "confidential_bigquery_key_${var.business_code}_${var.data_domain.name}_${var.env}"
        sa = [
          "serviceAccount:${data.google_bigquery_default_service_account.confidential_bigquery_sa.email}",
        ]
      },
    ]
  ])

  deidentification_key_sas = {
    sa-dataflow-controller         = "serviceAccount:${google_service_account.ingestion_service_accounts["sa-dataflow-controller"].email}",
    dataflow-service-producer-prod = "serviceAccount:service-${module.ingestion_project.project_number}@dataflow-service-producer-prod.iam.gserviceaccount.com",
    compute-system                 = "serviceAccount:service-${module.ingestion_project.project_number}@compute-system.iam.gserviceaccount.com",
  }

  keyrings = { for key_ring in var.key_rings : (split("/", key_ring)[3]) => key_ring }

  deidentification_keys = flatten([
    for key_name, key_id in local.deidentify_keys : [
      for sa_id, sa in local.deidentification_key_sas : [
        {
          key_id   = key_id
          name     = key_name
          location = split("/", key_id)[3]
          sa_id    = sa_id
          sa       = sa
        }
      ]
    ]
  ])
}

resource "time_sleep" "wait_for_sa" {
  create_duration = "30s"

  depends_on = [
    google_project_service_identity.nonconfidential,
    data.google_storage_project_service_account.gcs_account,
    data.google_storage_project_service_account.confidential_gcs_account,
    data.google_bigquery_default_service_account.nonconfidential_bigquery_sa,
    data.google_bigquery_default_service_account.confidential_bigquery_sa,
  ]
}

data "google_storage_project_service_account" "gcs_account" {
  project = module.ingestion_project.project_id
}

data "google_storage_project_service_account" "confidential_gcs_account" {
  project = module.confidential_project.project_id
}

data "google_bigquery_default_service_account" "nonconfidential_bigquery_sa" {
  project = module.nonconfidential_project.project_id
}

data "google_bigquery_default_service_account" "confidential_bigquery_sa" {
  project = module.confidential_project.project_id
}

module "data_mesh_keys" {
  source   = "../kms"
  for_each = { for key_ring in local.key_sa_map : "${key_ring.key}-${key_ring.location}" => key_ring }

  name                = each.value.key
  key_ring            = each.value.key_ring
  key_rotation_period = var.key_rotation_period
  prevent_destroy     = var.kms_key_prevent_destroy

  encrypter_decrypters = each.value.sa

  depends_on = [time_sleep.wait_for_sa]
}

resource "google_kms_crypto_key_iam_member" "deidentify_encrypt_decrypter" {
  for_each      = { for key in local.deidentification_keys : "${key.sa_id}-${key.location}" => key }
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  crypto_key_id = each.value.key_id
  member        = each.value.sa
}

module "ingestion_project_keys" {
  source   = "../kms"
  for_each = local.keyrings

  name                     = module.ingestion_project.project_id
  key_ring                 = each.value
  key_rotation_period      = var.key_rotation_period
  prevent_destroy          = var.kms_key_prevent_destroy
  enable_cloudbuild_deploy = true
  project_id               = local.env_kms_project_id

  app_infra_pipeline_service_account = local.app_infra_pipeline_service_accounts["${var.data_domain.name}-ingest"]

  encrypter_decrypters = [
    "serviceAccount:service-${module.ingestion_project.project_number}@gs-project-accounts.iam.gserviceaccount.com",
    "serviceAccount:service-${module.ingestion_project.project_number}@gcp-sa-pubsub.iam.gserviceaccount.com",
    "serviceAccount:${local.app_infra_pipeline_service_accounts["${var.data_domain.name}-ingest"]}",
  ]

  depends_on = [
    google_project_service_identity.ingestion,
  ]
}

module "nonconfidential_project_keys" {
  source   = "../kms"
  for_each = local.keyrings

  name                     = module.nonconfidential_project.project_id
  key_ring                 = each.value
  key_rotation_period      = var.key_rotation_period
  prevent_destroy          = var.kms_key_prevent_destroy
  enable_cloudbuild_deploy = true
  project_id               = local.env_kms_project_id

  app_infra_pipeline_service_account = local.app_infra_pipeline_service_accounts["${var.data_domain.name}-non-conf"]

  encrypter_decrypters = [
    "serviceAccount:service-${module.nonconfidential_project.project_number}@gs-project-accounts.iam.gserviceaccount.com",
    "serviceAccount:service-${module.nonconfidential_project.project_number}@gcp-sa-pubsub.iam.gserviceaccount.com",
    "serviceAccount:${local.app_infra_pipeline_service_accounts["${var.data_domain.name}-non-conf"]}"
  ]

  depends_on = [google_project_service_identity.nonconfidential]
}

module "confidential_project_keys" {
  source   = "../kms"
  for_each = local.keyrings

  name                     = module.confidential_project.project_id
  key_ring                 = each.value
  key_rotation_period      = var.key_rotation_period
  prevent_destroy          = var.kms_key_prevent_destroy
  enable_cloudbuild_deploy = true
  project_id               = local.env_kms_project_id

  app_infra_pipeline_service_account = local.app_infra_pipeline_service_accounts["${var.data_domain.name}-conf"]

  encrypter_decrypters = [
    "serviceAccount:service-${module.confidential_project.project_number}@gs-project-accounts.iam.gserviceaccount.com",
    "serviceAccount:service-${module.confidential_project.project_number}@gcp-sa-pubsub.iam.gserviceaccount.com",
    "serviceAccount:${local.app_infra_pipeline_service_accounts["${var.data_domain.name}-conf"]}"
  ]

  depends_on = [google_project_service_identity.confidential]
}
