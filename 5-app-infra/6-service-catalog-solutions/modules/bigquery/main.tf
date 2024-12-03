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
  iam_to_primitive = {
    "roles/bigquery.dataOwner" : "OWNER"
    "roles/bigquery.dataEditor" : "WRITER"
    "roles/bigquery.dataViewer" : "READER"
  }
}

resource "google_bigquery_dataset" "main" {
  dataset_id                  = var.dataset_id
  friendly_name               = var.dataset_name
  description                 = var.description
  location                    = var.region
  delete_contents_on_destroy  = var.delete_contents_on_destroy
  default_table_expiration_ms = var.default_table_expiration_ms
  max_time_travel_hours       = var.max_time_travel_hours
  project                     = var.project_id
  labels                      = var.dataset_labels

  default_encryption_configuration {
    kms_key_name = data.google_kms_crypto_key.key.id
  }

  dynamic "access" {
    for_each = var.access
    content {
      # BigQuery API converts IAM to primitive roles in its backend.
      # This causes Terraform to show a diff on every plan that uses IAM equivalent roles.
      # Thus, do the conversion between IAM to primitive role here to prevent the diff.
      role = lookup(local.iam_to_primitive, access.value.role, access.value.role)

      # Additionally, using null as a default value would lead to a permanant diff
      # See https://github.com/hashicorp/terraform-provider-google/issues/4085#issuecomment-516923872
      domain         = lookup(access.value, "domain", "")
      group_by_email = lookup(access.value, "group_by_email", "")
      user_by_email  = lookup(access.value, "user_by_email", "")
      special_group  = lookup(access.value, "special_group", "")
    }
  }
}
