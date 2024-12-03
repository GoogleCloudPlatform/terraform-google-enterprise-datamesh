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
  env = "development"
}

module "data_mesh" {
  source = "../../modules/data_mesh"

  env                       = local.env
  business_code             = "bu4"
  business_unit             = "business_unit_4"
  remote_state_bucket       = var.remote_state_bucket
  key_rings                 = local.environment_kms_key_ring
  ingestion_bucket_location = "us-central1"

  consumers_projects = [
    {
      name = "consumer-1"
    }
  ]

  data_domains = [
    {
      name = "domain-1"
    }
  ]

  create_resource_locations_policy = var.create_resource_locations_policy

  non_confidential_consumers_viewers_group_email = var.consumer_groups.non_confidential_data_viewer
  non_confidential_encrypted_data_viewer         = var.consumer_groups.non_confidential_encrypted_data_viewer
  non_confidential_fine_grained_data_viewer      = var.consumer_groups.non_confidential_fine_grained_data_viewer
  non_confidential_masked_data_viewer            = var.consumer_groups.non_confidential_masked_data_viewer
  confidential_consumers_viewers_group_email     = var.consumer_groups.confidential_data_viewer
}
