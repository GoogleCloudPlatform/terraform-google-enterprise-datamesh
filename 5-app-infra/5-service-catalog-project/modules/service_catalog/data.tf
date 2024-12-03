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


######################
# Data sources
######################

data "google_secret_manager_secret" "gh_infra_token" {
  project   = var.common_secrets_project_id
  secret_id = var.gh_token_secret
}

data "google_secret_manager_secret_version" "gh_infra_token" {
  project = var.common_secrets_project_id
  secret  = data.google_secret_manager_secret.gh_infra_token.id
}

data "google_service_account" "project_sa" {
  account_id = var.project_service_account_email
}

