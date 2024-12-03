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



module "data_access_management_cloud_run" {
  source     = "../cloud_run"
  project_id = var.project_id
  location   = var.region

  name                       = "${var.cloud_run_service.image_name}-${var.domain_name}"
  cloud_run_type             = "SERVICE"
  image_name                 = var.cloud_run_service.image_name
  image_tag                  = var.cloud_run_service.image_tag
  cloud_run_service_account  = var.cloud_run_service.service_account
  artifact_project_id        = var.cloud_run_service.artifact_project_id
  artifact_repository_name   = var.cloud_run_service.artifact_repository_name
  artifact_repository_folder = var.cloud_run_service.artifact_repository_folder
  environment_variables      = var.cloud_run_service.environment_variables

  memory_limit = "1Gi"
}



