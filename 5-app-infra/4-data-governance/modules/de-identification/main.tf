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
  parent      = "projects/${var.project_id}/locations/${var.dlp_location}"
  template_id = "${var.template_id_prefix}_${random_id.random_template_id_suffix.hex}"

}

resource "random_id" "random_template_id_suffix" {
  byte_length = 8

  keepers = {
    crypto_key  = var.crypto_key_name,
    wrapped_key = data.google_secret_manager_secret_version.wrapped_key.secret_data,
  }
}

resource "google_data_loss_prevention_deidentify_template" "deidentify_template" {
  parent       = local.parent
  description  = var.template_description
  display_name = var.template_display_name
  template_id  = local.template_id
  deidentify_config {
    record_transformations {
      field_transformations {
        dynamic "fields" {
          for_each = var.deidentify_field_transformations
          content {
            name = fields.value
          }
        }
        primitive_transformation {
          crypto_deterministic_config {
            crypto_key {
              kms_wrapped {
                wrapped_key     = chomp(data.google_secret_manager_secret_version.wrapped_key.secret_data)
                crypto_key_name = var.crypto_key_name
              }
            }
          }
        }
      }
    }
  }
}
