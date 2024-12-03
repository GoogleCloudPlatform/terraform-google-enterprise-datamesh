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

module "org_iam_member_data_mesh" {
  source = "./modules/parent-iam-member"

  member      = "serviceAccount:${google_service_account.terraform-env-sa["proj"].email}"
  parent_type = "organization"
  parent_id   = var.org_id
  roles       = ["roles/orgpolicy.policyAdmin"]
}

module "seed_project_iam_member_data_mesh" {
  source = "./modules/parent-iam-member"

  member      = "serviceAccount:${google_service_account.terraform-env-sa["proj"].email}"
  parent_type = "project"
  parent_id   = module.seed_bootstrap.seed_project_id
  roles       = ["roles/storage.admin"]
}

resource "google_project_service" "orgpolicy" {
  project = module.seed_bootstrap.seed_project_id
  service = "orgpolicy.googleapis.com"

  disable_on_destroy = true
}
