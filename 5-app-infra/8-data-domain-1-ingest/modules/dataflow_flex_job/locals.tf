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
  bucket_folder           = "flex-template-samples"
  container_spec_gcs_path = "${var.dataflow_gcs_bucket_url}/${local.bucket_folder}/${var.template_filename}"
  filtered_subnetwork = [
    for subnet in var.subnetworks : subnet
    if can(regex(var.region, subnet)) && !can(regex("-proxy", subnet))
  ]
  network    = "projects/${var.network_project_id}/global/networks/${var.network}"
  subnetwork = "https://www.googleapis.com/compute/v1/projects/${var.network_project_id}/regions/${var.region}/subnetworks/${local.filtered_subnetwork[0]}"
}
