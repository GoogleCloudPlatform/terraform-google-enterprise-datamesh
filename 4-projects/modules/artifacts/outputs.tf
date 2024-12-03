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

output "project_id" {
  value = try(module.app_infra_artifacts[0].project_id, "")
}

output "project_number" {
  value = try(module.app_infra_artifacts[0].project_number, "")
}

output "kms_keys" {
  value = { for location in keys(local.keyrings) : location => module.project_keys[location].kms_key }
}

output "cloudbuild_service_account_id" {
  value = try(google_service_account.cloudbuild_service_account[0].id, "")
}

output "github_repository_artifact_repo" {
  value = try(data.github_repository.artifact_repo, "")
}

