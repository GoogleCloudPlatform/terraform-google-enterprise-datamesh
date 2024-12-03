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
  service_identities_apis = [
    "bigquerydatatransfer.googleapis.com",
    "dlp.googleapis.com",
    "pubsub.googleapis.com",
    "run.googleapis.com",
    "storage.googleapis.com",
  ]
}

module "data_governance_project" {
  source = "../single_project"

  org_id                     = var.org_id
  billing_account            = var.billing_account
  folder_id                  = var.folder_id
  environment                = "common"
  vpc                        = "restricted"
  shared_vpc_host_project_id = var.shared_vpc_host_project_id
  shared_vpc_subnets         = var.shared_vpc_subnets
  project_budget             = var.project_budget
  project_prefix             = var.project_prefix

  activate_apis = [
    "artifactregistry.googleapis.com",
    "bigquery.googleapis.com",
    "bigqueryconnection.googleapis.com",
    "bigquerydatapolicy.googleapis.com",
    "cloudfunctions.googleapis.com",
    "cloudtasks.googleapis.com",
    "cloudkms.googleapis.com",
    "cloudbuild.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "cloudidentity.googleapis.com",
    "cloudscheduler.googleapis.com",
    "containerregistry.googleapis.com",
    "datacatalog.googleapis.com",
    "datalineage.googleapis.com",
    "dataplex.googleapis.com",
    "dlp.googleapis.com",
    "firestore.googleapis.com",
    "iam.googleapis.com",
    "monitoring.googleapis.com",
    "orgpolicy.googleapis.com",
    "pubsub.googleapis.com",
    "resourcesettings.googleapis.com",
    "run.googleapis.com",
    "secretmanager.googleapis.com",
    "storage.googleapis.com",
    "workflows.googleapis.com",
  ]

  vpc_service_control_attach_enabled = "true"
  vpc_service_control_perimeter_name = "accessPolicies/${var.access_context_manager_policy_id}/servicePerimeters/${var.perimeter_name}"
  vpc_service_control_sleep_duration = "60s"

  # Metadata
  project_suffix    = var.project_suffix
  application_name  = var.application_name
  billing_code      = var.billing_code
  primary_contact   = var.primary_contact
  secondary_contact = var.secondary_contact
  business_code     = var.business_code
}


resource "google_project_service_identity" "identity" {
  for_each = toset(local.service_identities_apis)
  provider = google-beta

  project = module.data_governance_project.project_id
  service = each.value
}

resource "time_sleep" "wait_for_service_identity" {
  create_duration = "10s"

  depends_on = [google_project_service_identity.identity]
}

data "google_secret_manager_secret" "dlp_kms_wrapper" {
  project   = var.secrets_project_id
  secret_id = var.dlp_kms_wrapper_secret
}
