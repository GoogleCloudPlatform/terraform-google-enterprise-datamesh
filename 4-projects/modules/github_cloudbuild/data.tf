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

data "google_project" "project" {
  project_id = var.app_infra_github_actions_project_id
}

data "google_secret_manager_secret" "gh_infra_token" {
  project   = var.secrets_project_id
  secret_id = var.gh_token_secret_id
}

data "google_secret_manager_secret_version" "gh_infra_token" {
  project = var.secrets_project_id
  secret  = data.google_secret_manager_secret.gh_infra_token.id
}

# data "github_repository" "infra" {
#   for_each = var.gh_common_project_repos.project_repos
#   name     = each.value

#   depends_on = [github_repository.infra]
# }
