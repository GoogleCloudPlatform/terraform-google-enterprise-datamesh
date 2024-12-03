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

data "google_client_config" "account" {}

resource "terraform_data" "image_tag" {
  input = var.tag_engine_image_tag
}

locals {
  environment_variables = {
    TAG_ENGINE_SA            = local.data_governance_sa_tag_engine
    TAG_CREATOR_SA           = local.data_governance_sa_tag_creator
    TAG_ENGINE_PROJECT       = local.data_governance_project_id
    TAG_ENGINE_REGION        = var.region
    FIRESTORE_PROJECT        = local.data_governance_project_id
    FIRESTORE_DB             = module.firestore_tag_engine.firestore_database_name
    INJECTOR_QUEUE           = var.tag_engine_injector_queue_name
    WORK_QUEUE               = var.tag_engine_work_queue_name
    BIGQUERY_REGION          = var.region
    FILESET_REGION           = var.region
    SPANNER_REGION           = var.region
    ENABLE_AUTH              = "True"
    OAUTH_CLIENT_CREDENTIALS = "te_client_secret.json"
    ENABLE_TAG_HISTORY       = "True"
    TAG_HISTORY_PROJECT      = local.data_governance_project_id
    TAG_HISTORY_DATASET      = var.tag_history_dataset_name
    ENABLE_JOB_METADATA      = "True"
    JOB_METADATA_PROJECT     = local.data_governance_project_id
    JOB_METADATA_DATASET     = "job_metadata"

  }

  # Convert the environment variables map to a list of objects
  env_vars_list = concat([for key, value in local.environment_variables : {
    name  = key
    value = value
    }],
    [
      {
        name  = "SERVICE_URL"
        value = module.tag_engine.cloud_run_service.uri
      }
  ])

  # Create the updated environment variables list with SERVICE_URL included
  base_orchistration_workflows = [
    "oauth-token",
  ]
}

module "tag_engine" {
  source     = "../../modules/cloud_run"
  project_id = local.data_governance_project_id
  location   = var.region

  name                       = "tag_engine_api"
  cloud_run_type             = "SERVICE"
  image_name                 = var.tag_engine_api_image_name
  image_tag                  = var.tag_engine_image_tag
  cloud_run_service_account  = local.data_governance_sa_tag_engine
  artifact_project_id        = local.artifact_project_id
  artifact_repository_name   = var.artifact_repository_name
  artifact_repository_folder = var.artifact_repository_folder

  environment_variables = local.environment_variables

  memory_limit = "1Gi"

  depends_on = [
    module.firestore_tag_engine,
    module.bigquery_tag_history_logs,
  ]

}


resource "terracurl_request" "patch_tag_engine_api" {
  provider = terracurl

  name   = "patch_tag_engine_api"
  method = "PATCH"
  headers = {
    Authorization = "Bearer ${data.google_client_config.account.access_token}"
    Content-Type  = "application/json"
  }
  url            = "https://run.googleapis.com/v2/${module.tag_engine.cloud_run_service.id}?updateMask=template.containers"
  response_codes = [200, 204, 409]

  request_body = jsonencode({
    "template" : {
      "containers" : [
        {
          "image" : module.tag_engine.image_name,
          "env" : local.env_vars_list
          "resources" : {
            "limits" : {
              "cpu" : "1",
              "memory" : "1Gi"
            }
          }
        }
      ]
    }
  })

  lifecycle {
    replace_triggered_by = [terraform_data.image_tag]
    ignore_changes       = [headers]
  }

  depends_on = [module.tag_engine]
}

resource "time_sleep" "wait_for_tag_engine_api" {
  depends_on = [terracurl_request.patch_tag_engine_api]

  create_duration = "60s"
}

// only one task needs to be defined here. It is ubiquitous across all workflows, regardless of the environment
resource "google_workflows_workflow" "tag_engine_base" {
  for_each = toset(local.base_orchistration_workflows)

  project = local.data_governance_project_id
  region  = var.region
  name    = each.value

  service_account = local.cloud_run_sa
  source_contents = templatefile(
    "${path.module}/../../static_data/tag_engine_orchestration/${replace(each.value, "-", "_")}.yaml",
    {
      project_id_gov = local.data_governance_project_id
      cloud_run_sa   = local.cloud_run_sa
    }
  )
}

resource "google_cloud_tasks_queue" "tag_engine" {
  for_each = toset([var.tag_engine_injector_queue_name, var.tag_engine_work_queue_name])

  project  = local.data_governance_project_id
  name     = each.value
  location = var.region

  rate_limits {
    max_concurrent_dispatches = 100
  }
  retry_config {
    max_attempts = 2
  }
}

############################
# Tag Engine Development
############################

module "tag_engine_development" {
  source = "../../modules/tag_engine"

  project_id  = local.data_governance_project_id
  region      = var.region
  environment = "development"

  tag_engine_config_path        = "${path.module}/../../static_data/tag_engine_configs"
  tag_engine_orchistration_path = "${path.module}/../../static_data/tag_engine_orchestration"
  tag_engine_service_uri        = module.tag_engine.cloud_run_service.uri
  pricing_export_dataset_name   = var.pricing_export_dataset_name

  data_domain_projects = local.data_domain_non_conf_projects_dev

  cloud_run_sa = local.cloud_run_sa

  dlp_job_inspect_datasets = var.dlp_job_inspect_datasets
  data_catalog_environment = module.data_catalog_development

  depends_on = [
    module.firestore_tag_engine,
    module.bigquery_tag_history_logs,
    module.data_catalog_development,
    time_sleep.wait_for_tag_engine_api,
  ]

}

############################
# Tag Engine Non Production
############################

module "tag_engine_nonproduction" {
  source = "../../modules/tag_engine"

  project_id  = local.data_governance_project_id
  region      = var.region
  environment = "nonproduction"

  tag_engine_config_path        = "${path.module}/../../static_data/tag_engine_configs"
  tag_engine_orchistration_path = "${path.module}/../../static_data/tag_engine_orchestration"
  tag_engine_service_uri        = module.tag_engine.cloud_run_service.uri
  pricing_export_dataset_name   = var.pricing_export_dataset_name

  data_domain_projects = local.data_domain_non_conf_projects_nonp

  cloud_run_sa = local.cloud_run_sa

  dlp_job_inspect_datasets = var.dlp_job_inspect_datasets
  data_catalog_environment = module.data_catalog_nonproduction

  depends_on = [
    module.firestore_tag_engine,
    module.bigquery_tag_history_logs,
    module.data_catalog_nonproduction,
    time_sleep.wait_for_tag_engine_api,
  ]

}

############################
# Tag Engine Production
############################

module "tag_engine_production" {
  source = "../../modules/tag_engine"

  project_id  = local.data_governance_project_id
  region      = var.region
  environment = "production"

  tag_engine_config_path        = "${path.module}/../../static_data/tag_engine_configs"
  tag_engine_orchistration_path = "${path.module}/../../static_data/tag_engine_orchestration"
  tag_engine_service_uri        = module.tag_engine.cloud_run_service.uri
  pricing_export_dataset_name   = var.pricing_export_dataset_name

  data_domain_projects = local.data_domain_non_conf_projects_prod

  cloud_run_sa = local.cloud_run_sa

  dlp_job_inspect_datasets = var.dlp_job_inspect_datasets
  data_catalog_environment = module.data_catalog_production

  depends_on = [
    module.firestore_tag_engine,
    module.bigquery_tag_history_logs,
    module.data_catalog_production,
    time_sleep.wait_for_tag_engine_api,
  ]

}
