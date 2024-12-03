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
  default_consumer_apis = [
    "bigquery.googleapis.com",
    "cloudkms.googleapis.com",
  ]
}

module "consumers_project" {
  source = "../single_project"

  org_id                   = local.org_id
  billing_account          = local.billing_account
  folder_id                = var.folder_name
  environment              = var.env
  project_budget           = var.project_budget
  project_prefix           = local.project_prefix
  enable_cloudbuild_deploy = true

  # Metadata
  project_suffix    = var.consumers_project.name
  application_name  = "${var.business_code}-${var.consumers_project.name}"
  billing_code      = "1234"
  primary_contact   = "example@example.com"
  secondary_contact = "example2@example.com"
  business_code     = var.business_code
  activate_apis     = concat(local.default_consumer_apis, var.consumers_project.apis)

  app_infra_pipeline_service_accounts = local.app_infra_pipeline_service_accounts
  sa_roles = {
    (var.consumers_project.name) = [
      "roles/bigquery.dataEditor"
    ]
  }
}
