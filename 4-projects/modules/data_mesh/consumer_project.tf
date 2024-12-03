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

module "consumers_projects" {
  source = "../data_consumer"

  for_each = { for project in var.consumers_projects : project.name => project }

  env           = var.env
  business_unit = var.business_unit
  business_code = var.business_code

  consumers_project   = each.value
  remote_state_bucket = var.remote_state_bucket

  folder_name = google_folder.consumers_folder.name

  project_budget = var.project_budget
  key_rings      = var.key_rings
}
