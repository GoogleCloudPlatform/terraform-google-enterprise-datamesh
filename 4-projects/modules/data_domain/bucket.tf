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


resource "google_storage_bucket" "data_ingestion_bucket" {
  project                     = module.ingestion_project.project_id
  name                        = "${var.gcs_bucket_prefix}-${local.org_id}-${var.data_domain.name}-data-ingestion-${var.env}"
  location                    = var.ingestion_bucket_location
  uniform_bucket_level_access = true
  force_destroy               = true
  storage_class               = "STANDARD"

  encryption {
    default_kms_key_name = module.ingestion_project_keys[var.ingestion_bucket_location].kms_key.id
  }
}
