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

##########################################
# Data Quality Scanning
##########################################

module "data_quality_scanning_development_non_confidential" {
  for_each = { for dataset in var.dlp_job_inspect_datasets : "${dataset.domain_name}-${dataset.inspection_dataset}" => dataset if dataset.environment == "development" }

  source     = "../../modules/cloud_run"
  project_id = local.data_governance_project_id
  location   = var.region

  name                       = "dq_scanning_${replace(each.key, "-", "_")}"
  image_name                 = var.data_quality_image_name
  image_tag                  = var.data_quality_image_tag
  image_region               = var.region
  artifact_project_id        = local.artifact_project_id
  artifact_repository_name   = var.artifact_repository_name
  artifact_repository_folder = var.artifact_repository_folder
  cloud_run_service_account  = local.cloud_run_sa

  args = [
    local.data_domain_non_conf_projects_dev[each.value.domain_name].project_id,
    local.data_governance_project_id,
    var.region,
    module.bigquery_dataquality_development[each.value.domain_name].bigquery_dataset.dataset_id,
    each.value.inspection_dataset,
    join(",", each.value.inspecting_table_ids)
  ]

  depends_on = [module.bigquery_dataquality_development]
}

module "data_quality_scanning_nonproduction_non_confidential" {
  for_each   = { for dataset in var.dlp_job_inspect_datasets : "${dataset.domain_name}-${dataset.inspection_dataset}" => dataset if dataset.environment == "nonproduction" }
  source     = "../../modules/cloud_run"
  project_id = local.data_governance_project_id
  location   = var.region

  name                       = "dq_scanning_${replace(each.key, "-", "_")}"
  image_name                 = var.data_quality_image_name
  image_tag                  = var.data_quality_image_tag
  image_region               = var.region
  artifact_project_id        = local.artifact_project_id
  artifact_repository_name   = var.artifact_repository_name
  artifact_repository_folder = var.artifact_repository_folder
  cloud_run_service_account  = local.cloud_run_sa

  args = [
    local.data_domain_non_conf_projects_nonp[each.value.domain_name].project_id,
    local.data_governance_project_id,
    var.region,
    module.bigquery_dataquality_nonproduction[each.value.domain_name].bigquery_dataset.dataset_id,
    each.value.inspection_dataset,
    join(",", each.value.inspecting_table_ids)
  ]

  depends_on = [module.bigquery_dataquality_nonproduction]
}

module "data_quality_scanning_production" {
  for_each   = { for dataset in var.dlp_job_inspect_datasets : "${dataset.domain_name}-${dataset.inspection_dataset}" => dataset if dataset.environment == "production" }
  source     = "../../modules/cloud_run"
  project_id = local.data_governance_project_id
  location   = var.region

  name                       = "dq_scanning_${replace(each.key, "-", "_")}"
  image_name                 = var.data_quality_image_name
  image_tag                  = var.data_quality_image_tag
  image_region               = var.region
  artifact_project_id        = local.artifact_project_id
  artifact_repository_name   = var.artifact_repository_name
  artifact_repository_folder = var.artifact_repository_folder
  cloud_run_service_account  = local.cloud_run_sa

  args = [
    local.data_domain_non_conf_projects_prod[each.value.domain_name].project_id,
    local.data_governance_project_id,
    var.region,
    module.bigquery_dataquality_production[each.value.domain_name].bigquery_dataset.dataset_id,
    each.value.inspection_dataset,
    join(",", each.value.inspecting_table_ids)
  ]

  depends_on = [module.bigquery_dataquality_production]
}
