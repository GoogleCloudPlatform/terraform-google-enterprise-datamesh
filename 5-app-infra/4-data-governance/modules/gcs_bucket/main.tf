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

resource "random_string" "bucket_name" {
  length  = 5
  upper   = false
  numeric = true
  lower   = true
  special = false
}

resource "google_storage_bucket" "gcs_bucket" {
  project                     = var.project_id
  name                        = "${var.bucket_name}-${random_string.bucket_name.result}"
  location                    = var.bucket_location
  storage_class               = var.storage_class
  uniform_bucket_level_access = var.uniform_bucket_level_access

  force_destroy = var.force_destroy

  versioning {
    enabled = var.enable_versioning
  }

  encryption {
    default_kms_key_name = var.default_kms_key_name
  }
}
