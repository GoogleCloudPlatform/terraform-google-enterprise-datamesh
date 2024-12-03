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
 * limitations under the License.```
 */

resource "google_dataflow_flex_template_job" "dataflow_flex_job" {
  provider = google-beta

  project = var.project_id
  name    = var.name
  region  = var.region

  autoscaling_algorithm   = var.autoscaling_algorithm
  container_spec_gcs_path = local.container_spec_gcs_path
  enable_streaming_engine = var.enable_streaming_engine
  ip_configuration        = var.ip_configuration

  additional_experiments = var.additional_experiments
  kms_key_name           = data.google_kms_crypto_key.data_ingestion_key.id
  service_account_email  = var.service_account_email

  launcher_machine_type = var.launcher_machine_type
  max_workers           = var.max_workers
  num_workers           = var.num_workers
  network               = local.network
  subnetwork            = local.subnetwork

  sdk_container_image = var.sdk_container_image

  staging_location = var.staging_location
  temp_location    = var.temp_location

  labels                 = var.labels
  parameters             = merge(var.parameters, var.additional_parameters)
  transform_name_mapping = var.transform_name_mapping
}
