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


module "record_manager" {
  source     = "../cloud_run"
  project_id = var.project_id
  location   = var.region

  name                       = "record_manager_${var.data_domain_name}_${var.environment}"
  image_name                 = var.record_manager_image_name
  image_tag                  = var.record_manager_image_tag
  image_region               = var.region
  artifact_project_id        = var.artifact_project_id
  artifact_repository_name   = var.artifact_repository_name
  artifact_repository_folder = var.artifact_repository_folder
  cloud_run_service_account  = var.cloud_run_service_account

  environment_variables = {
    PARAM_FILE = "gs://${var.record_manager_config_bucket}/${var.environment}/${var.data_domain_name}/record_manager_config.json"
  }

  depends_on = [
    google_storage_bucket_object.rendered_json_file
  ]
}


resource "google_storage_bucket_object" "rendered_json_file" {
  name   = "${var.environment}/${var.data_domain_name}/record_manager_config.json"
  bucket = var.record_manager_config_bucket
  content = templatefile(var.record_manager_config_template_file, {
    template_id               = var.record_manager_config["template_id"]
    template_project          = var.project_id
    template_region           = var.region
    retention_period_field    = var.record_manager_config["retention_period_field"]
    expiration_action_field   = var.record_manager_config["expiration_action_field"]
    projects_in_scope         = [var.non_production_project_id, var.project_id]
    datasets_in_scope         = var.datasets_in_scope
    bigquery_region           = var.region
    snapshot_project          = var.project_id
    snapshot_dataset          = var.record_manager_config["snapshot_dataset"]
    snapshot_retention_period = var.record_manager_config["snapshot_retention_period"]
    archives_bucket           = var.record_manager_config["archives_bucket"]
    export_format             = var.record_manager_config["export_format"]
    archives_project          = var.project_id
    archives_dataset          = var.record_manager_config["archives_dataset"]
    remote_connection         = var.remote_connection
    tag_engine_endpoint       = var.tag_engine_endpoint
    mode                      = var.record_manager_config["mode"]
  })
}
