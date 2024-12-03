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

output "cloud_run_job" {
  description = "Cloud Run Job"
  value       = try(google_cloud_run_v2_job.cloud_run[0], null)
}

output "cloud_run_service" {
  description = "Cloud Run Service"
  value       = try(google_cloud_run_v2_service.cloud_run[0], null)
}

output "image_name" {
  description = "Cloud Run image name"
  value       = local.fqdn_image_name
}