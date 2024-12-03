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
  indexes = yamldecode(file(var.firestore_index_config_file))
}

resource "google_firestore_database" "firestore_database" {
  project                           = var.project_id
  name                              = var.database_id
  location_id                       = var.location_id
  type                              = var.firestore_type
  delete_protection_state           = var.delete_protection_state
  deletion_policy                   = var.deletion_policy
  concurrency_mode                  = var.concurrency_mode
  point_in_time_recovery_enablement = var.point_in_time_recovery_enablement

  dynamic "cmek_config" {
    for_each = var.kms_key_name != null ? [1] : []

    content {
      kms_key_name = var.kms_key_name
    }
  }
}

resource "google_firestore_index" "firestore_index" {
  for_each   = { for i, idx in local.indexes.indexes : "${idx.collection}-${tostring(i)}" => idx }
  project    = var.project_id
  database   = google_firestore_database.firestore_database.name
  collection = each.value.collection

  dynamic "fields" {
    for_each = [for field in each.value.fields : {
      field_path = split(":", field.field)[0]
      order      = length(split(":", field.field)) > 1 ? split(":", field.field)[1] : "ASCENDING"
    }]

    content {
      field_path = fields.value.field_path
      order      = fields.value.order
    }
  }
}
