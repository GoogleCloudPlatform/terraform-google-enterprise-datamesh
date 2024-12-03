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

module "data_access_management" {
  source   = "../../modules/data_access_management"
  for_each = toset([for domain in var.dlp_job_inspect_datasets : domain.domain_name])

  project_id  = local.data_governance_project_id
  region      = var.region
  domain_name = each.key

  cloud_run_service = {
    image_name                 = var.data_access_management_image_name
    image_tag                  = var.data_access_management_image_tag
    service_account            = local.data_access_management_sa
    artifact_project_id        = local.artifact_project_id
    artifact_repository_name   = var.artifact_repository_name
    artifact_repository_folder = var.artifact_repository_folder
    environment_variables = {
      # Confidential Data Access
      CONFIDENTIAL_DATA_VIEWER_GROUP = local.consumer_groups_email.conf_data_viewer
      # Non Confidential Data Access
      NON_CONFIDENTIAL_DATA_VIEWER_GROUP              = local.consumer_groups_email.data_viewer
      NON_CONFIDENTIAL_FINE_GRAINED_DATA_VIEWER_GROUP = local.consumer_groups_email.fine_grained_data_viewer
      NON_CONFIDENTIAL_ENCRYPTED_DATA_VIEWER_GROUP    = local.consumer_groups_email.encrypted_data_viewer
      NON_CONFIDENTIAL_MASKED_DATA_VIEWER_GROUP       = local.consumer_groups_email.masked_data_viewer
    }
  }
}
