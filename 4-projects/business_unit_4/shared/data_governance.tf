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

module "data_governance" {
  source = "../../modules/data_governance"

  org_id          = local.org_id
  folder_id       = local.common_folder_name
  billing_account = local.billing_account

  project_suffix    = "data-governance"
  application_name  = "app-infra-data-governance"
  billing_code      = "1234"
  primary_contact   = "example@example.com"
  secondary_contact = "example2@example.com"
  business_code     = "bu4"

  shared_kms_key_ring = local.shared_kms_key_ring

  shared_vpc_host_project_id = local.restricted_host_project_id
  shared_vpc_subnets         = local.restricted_subnets_self_links

  project_budget = var.project_budget
  project_prefix = local.project_prefix

  access_context_manager_policy_id = local.access_context_manager_policy_id

  perimeter_name         = local.perimeter_name
  secrets_project_id     = local.common_secrets_project_id
  dlp_kms_wrapper_secret = local.dlp_kms_wrapper_secret_name
  kms_project_id         = local.shared_kms_project_id

  key_rotation_period = var.key_rotation_period

  terraform_service_account = module.github_cloudbuild[0].terraform_service_accounts["data-governance"]

  encrypted_data_viewers_group = var.consumer_groups.non_confidential_encrypted_data_viewer

  # Dependencies
  depends_on = [
    module.app_infra_github_cloudbuild_project,
    module.github_cloudbuild
  ]
}
