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


module "report_engine_cloud_run" {
  source     = "../cloud_run"
  project_id = var.project_id
  location   = var.region

  name                       = "${var.cloud_run_service.image_name}-${var.domain_name}-${var.environment}"
  cloud_run_type             = "SERVICE"
  image_name                 = var.cloud_run_service.image_name
  image_tag                  = var.cloud_run_service.image_tag
  cloud_run_service_account  = var.cloud_run_service.service_account
  artifact_project_id        = var.cloud_run_service.artifact_project_id
  artifact_repository_name   = var.cloud_run_service.artifact_repository_name
  artifact_repository_folder = var.cloud_run_service.artifact_repository_folder

  environment_variables = merge(var.cloud_run_service.environment_variables,
    {
      "REGION"            = var.region
      "PROJECT_ID_GOV"    = var.project_id
      "DATA_ASSETS_TOPIC" = var.cdmc_data_assets_topic
  })

  memory_limit = "1Gi"

}


resource "google_workflows_workflow" "orchestration" {
  project = var.project_id

  name            = "generate-report-${var.domain_name}-${var.environment}"
  region          = var.region
  service_account = var.worklow_run_sa
  source_contents = templatefile(var.report_engine_orchestration_path, {
    project_id_gov         = var.project_id
    report_engine_url      = module.report_engine_cloud_run.cloud_run_service.uri
    report_engine_endpoint = "/generate?orgId=${var.organization_id}&projectId=${var.data_domain_project_id}&topicProjectId=${var.project_id}&topic=${var.cdmc_controls_topic}&projectNumber=${var.data_domain_project_number}&controls=${var.controls}"
    cloud_run_sa           = var.worklow_run_sa
  })
  depends_on = [module.report_engine_cloud_run]
}
