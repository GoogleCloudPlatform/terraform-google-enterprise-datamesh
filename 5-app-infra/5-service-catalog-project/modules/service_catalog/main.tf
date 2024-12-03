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

###########
# Buckets
###########

resource "google_storage_bucket" "solutions_bucket" {
  name     = "${var.bucket_name_prefix}-solutions-${var.project_id}"
  project  = var.project_id
  location = var.region

  uniform_bucket_level_access = true

  versioning {
    enabled = true // required by the service catalog
  }

  encryption {
    default_kms_key_name = var.service_catalog_kms_keys[var.region].id
  }
}

// Bind Storage Admin role to the project's service account
resource "google_storage_bucket_iam_binding" "solutions_bucket" {
  bucket  = google_storage_bucket.solutions_bucket.id
  members = ["serviceAccount:${var.project_service_account_email}"]
  role    = "roles/storage.admin"
}

resource "google_storage_bucket_iam_member" "solutions_bucket_roles" {
  for_each = merge(flatten([for role, members in var.bucket_roles : {
    for member in members : "${member}--${role}" => {
      role = role, member = member
    } }
  ])...)

  bucket = google_storage_bucket.solutions_bucket.id
  member = each.value.member
  role   = each.value.role
}

resource "google_storage_bucket" "log_bucket" {
  name     = "${var.bucket_name_prefix}-build-logs-${var.project_id}"
  project  = var.project_id
  location = var.region

  uniform_bucket_level_access = true

  encryption {
    default_kms_key_name = var.service_catalog_kms_keys[var.region].id
  }
}

// Bind Storage Admin role to the project's service account
resource "google_storage_bucket_iam_binding" "log_bucket" {
  bucket  = google_storage_bucket.log_bucket.id
  members = ["serviceAccount:${var.project_service_account_email}"]
  role    = "roles/storage.admin"
}
