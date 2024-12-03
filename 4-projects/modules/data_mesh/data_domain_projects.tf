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

module "data_domain_projects" {
  source = "../data_domain"

  for_each    = { for domain in var.data_domains : domain.name => domain }
  data_domain = each.value

  env           = var.env
  business_unit = var.business_unit
  business_code = var.business_code

  ingestion_bucket_location = var.ingestion_bucket_location
  remote_state_bucket       = var.remote_state_bucket

  enable_bigquery_read_roles = var.enable_bigquery_read_roles

  folder_name = google_folder.data_domain_folder[each.key].name

  project_budget = var.project_budget
  key_rings      = var.key_rings

  non_confidential_consumers_viewers_group_email = var.non_confidential_consumers_viewers_group_email
  non_confidential_encrypted_data_viewer         = var.non_confidential_encrypted_data_viewer
  non_confidential_fine_grained_data_viewer      = var.non_confidential_fine_grained_data_viewer
  non_confidential_masked_data_viewer            = var.non_confidential_masked_data_viewer
  confidential_consumers_viewers_group_email     = var.confidential_consumers_viewers_group_email

  create_resource_locations_policy = var.create_resource_locations_policy
}
