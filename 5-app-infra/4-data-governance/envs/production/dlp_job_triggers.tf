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
# Data Scan output Datasets
##########################################

module "data_job_triggers_development" {
  for_each = toset(distinct([for domain in var.dlp_job_inspect_datasets : domain.domain_name if domain.environment == "development"]))
  source   = "../../modules/dlp_job_trigger"

  project_id      = local.data_governance_project_id
  data_project_id = local.data_domain_non_conf_projects_dev[each.key].project_id

  dlp_location                       = var.region
  dlp_job_recurrence_period_duration = "86400s"

  dlp_job_inspect_datasets = var.dlp_job_inspect_datasets
}

module "data_job_triggers_nonproduction" {
  for_each = toset(distinct([for domain in var.dlp_job_inspect_datasets : domain.domain_name if domain.environment == "nonproduction"]))
  source   = "../../modules/dlp_job_trigger"

  project_id      = local.data_governance_project_id
  data_project_id = local.data_domain_non_conf_projects_nonp[each.key].project_id

  dlp_location                       = var.region
  dlp_job_recurrence_period_duration = "86400s"

  dlp_job_inspect_datasets = var.dlp_job_inspect_datasets

  dlp_job_status = "PAUSED"
}

module "data_job_triggers_production" {
  for_each = toset(distinct([for domain in var.dlp_job_inspect_datasets : domain.domain_name if domain.environment == "production"]))
  source   = "../../modules/dlp_job_trigger"

  project_id      = local.data_governance_project_id
  data_project_id = local.data_domain_non_conf_projects_prod[each.key].project_id

  dlp_location                       = var.region
  dlp_job_recurrence_period_duration = "86400s"

  dlp_job_inspect_datasets = var.dlp_job_inspect_datasets

  dlp_job_status = "PAUSED"
}
