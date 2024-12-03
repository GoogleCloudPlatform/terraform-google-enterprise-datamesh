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

output "common_kms_project_number" {
  description = "The org Cloud Key Management Service (KMS) project Number"
  value       = module.common_kms.project_number
}

output "org_secrets_project_number" {
  description = "The org secrets project ID"
  value       = module.org_secrets.project_number
}

output "key_rings" {
  description = "Keyring Names created"
  value       = values(module.kms_keyrings)[*].keyring
}

output "gh_token_secret" {
  description = "The GitHub token secret ID"
  value       = google_secret_manager_secret.gh_secrets.secret_id
}

output "kms_wrapper_secret" {
  description = "The KMS wrapper secret ID"
  value       = google_secret_manager_secret.kms_wrapper.secret_id
}

output "dlp_kms_wrapper_secret" {
  description = "The secret which holds the KMS wrapper secret ID for DLP Deidentify API"
  value       = google_secret_manager_secret.dlp_kms_wrapper.secret_id
}

output "tag_engine_oauth_client_id_secret" {
  value       = google_secret_manager_secret.tag_engine_oauth_client_id.secret_id
  description = "The secret which holds the Tag Engine OAuth Client ID"
}
