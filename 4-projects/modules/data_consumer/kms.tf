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
  keyrings = { for key_ring in var.key_rings : (split("/", key_ring)[3]) => key_ring }
}
data "google_bigquery_default_service_account" "bigquery" {
  project = module.consumers_project.project_id
}
module "consumer_project_keys" {
  source   = "../kms"
  for_each = local.keyrings

  name                     = module.consumers_project.project_id
  key_ring                 = each.value
  key_rotation_period      = var.key_rotation_period
  prevent_destroy          = var.kms_key_prevent_destroy
  enable_cloudbuild_deploy = true
  project_id               = module.consumers_project.project_id

  app_infra_pipeline_service_account = local.app_infra_pipeline_service_accounts[var.consumers_project.name]

  encrypter_decrypters = [
    "serviceAccount:${data.google_bigquery_default_service_account.bigquery.email}",
  ]
}
