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

variable "app_infra_github_actions_project_id" {
  description = "The project id where the actions are configured"
  type        = string
}

variable "default_region" {
  description = "Defualt Region"
  type        = string
}

variable "bucket_prefix" {
  description = "Name prefix to use for state bucket created."
  type        = string
  default     = "bkt"
}

variable "secrets_project_id" {
  description = "The project id where the secrets are stored"
  type        = string
}

variable "terraform_docker_tag_version" {
  description = "TAG version of the terraform docker image."
  type        = string
  default     = "1.5.7"
}

variable "gcloud_docker_tag_version" {
  description = "TAG version of the gcloud docker image."
  type        = string
  default     = "482.0.0-alpine"
}

variable "billing_account" {
  description = "The ID of the billing account to associated this project with."
  type        = string
}

#################################
# GitHub
#################################
variable "gh_common_project_repos" {
  description = "GitHub Common Project Repos"
  type = object({
    owner         = string
    project_repos = map(string)
  })
  default = null
}

variable "github_app_infra_token" {
  description = "A fine-grained personal access token for the user or organization. See https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token#creating-a-fine-grained-personal-access-token"
  type        = string
  sensitive   = true
}

variable "github_app_installation_id" {
  description = "Github App Installation ID"
  type        = number
}

variable "gh_token_secret_id" {
  description = "id of github token secret"
  type        = string
}

variable "create_repositories" {
  description = "Boolean to create repositories"
  type        = bool
  default     = true
}

variable "org_id" {
  description = "value of org id"
  type        = string
}

variable "remote_project_state_bucket" {
  description = "value of remote project state bucket"
  type        = string
}
