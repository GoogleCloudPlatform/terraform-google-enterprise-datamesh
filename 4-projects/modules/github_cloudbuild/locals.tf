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
  # workspace_sa_email = { for k, v in module.github_tf_workspace : k => element(split("/", v.cloudbuild_sa), length(split("/", v.cloudbuild_sa)) - 1) }
  created_repos     = toset([for repo in google_cloudbuildv2_repository.github : repo.name])
  artifact_buckets  = { for k, ws in module.github_tf_workspace : k => split("/", ws.artifacts_bucket)[length(split("/", ws.artifacts_bucket)) - 1] }
  state_buckets     = { for k, ws in module.github_tf_workspace : k => split("/", ws.state_bucket)[length(split("/", ws.state_bucket)) - 1] }
  log_buckets       = { for k, ws in module.github_tf_workspace : k => split("/", ws.logs_bucket)[length(split("/", ws.logs_bucket)) - 1] }
  plan_triggers_id  = [for ws in module.github_tf_workspace : ws.cloudbuild_plan_trigger_id]
  apply_triggers_id = [for ws in module.github_tf_workspace : ws.cloudbuild_apply_trigger_id]

  # sa_mapping = {
  #   for k, v in toset(var.gh_common_project_repos.project_repos) : k => {
  #     sa_name   = google_service_account.terraform-infra-sa[k].name
  #     attribute = "attribute.repository/${var.gh_common_project_repos.owner}/${var.infra_project_prefix}-${k}"
  #   }
  # }

  common_secrets = {
    "PROJECT_ID" : var.app_infra_github_actions_project_id,
    "TF_VAR_gh_token" : var.github_app_infra_token
  }
  sa_secrets = [
    for k, v in var.gh_common_project_repos.project_repos : {
      repository      = var.create_repositories ? github_repository.infra[k].name : v
      secret_name     = "SERVICE_ACCOUNT_EMAIL"
      plaintext_value = module.github_tf_workspace[k].cloudbuild_sa
      config          = k
    }
  ]

  secrets_list = flatten([
    for k, v in var.gh_common_project_repos.project_repos : [
      for secret, plaintext in local.common_secrets : {
        config          = k
        secret_name     = secret
        plaintext_value = plaintext
        repository      = var.create_repositories ? github_repository.infra[k].name : v
      }
    ]
  ])

  gh_secrets = {
    for v in concat(local.sa_secrets, local.secrets_list) : "${v.config}.${v.secret_name}" => v
  }
}
