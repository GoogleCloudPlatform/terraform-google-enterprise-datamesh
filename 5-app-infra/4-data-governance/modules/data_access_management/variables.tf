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


variable "project_id" {
  description = "Project ID"
  type        = string
}

variable "region" {
  type = string
}

variable "domain_name" {
  description = "Domain name"
  type        = string
}

variable "cloud_run_service" {
  type = object({
    image_name                 = string,
    image_tag                  = string,
    service_account            = string,
    artifact_project_id        = string,
    artifact_repository_name   = string
    artifact_repository_folder = string
    environment_variables      = map(string)
  })

}
