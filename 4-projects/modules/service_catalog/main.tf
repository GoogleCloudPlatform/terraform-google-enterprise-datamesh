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
  service_catalog_tf_sa_roles = [
    "roles/cloudbuild.builds.editor",
    "roles/iam.serviceAccountAdmin",
    "roles/cloudbuild.connectionAdmin",
    "roles/cloudkms.cryptoKeyEncrypter",
    "roles/cloudbuild.builds.editor",
    "roles/secretmanager.admin",
    "roles/storage.admin",
  ]

  project_sa_roles = [
    "roles/logging.logWriter",
    "roles/storage.admin",
  ]
}

module "service_catalog_project" {
  source = "../../modules/single_project"

  org_id                     = var.org_id
  billing_account            = var.billing_account
  folder_id                  = var.folder_id
  environment                = "common"
  vpc                        = "restricted"
  shared_vpc_host_project_id = var.shared_vpc_host_project_id
  shared_vpc_subnets         = var.shared_vpc_subnets
  project_budget             = var.project_budget
  project_prefix             = var.project_prefix

  enable_cloudbuild_deploy            = true
  app_infra_pipeline_service_accounts = var.app_infra_pipeline_service_accounts

  activate_apis = [
    "logging.googleapis.com",
    "storage.googleapis.com",
    "serviceusage.googleapis.com",
    "secretmanager.googleapis.com",
    "cloudbuild.googleapis.com",
    "cloudresourcemanager.googleapis.com"
  ]

  vpc_service_control_attach_enabled = "false"

  # Metadata
  project_suffix    = var.project_suffix
  application_name  = var.application_name
  billing_code      = var.billing_code
  primary_contact   = var.primary_contact
  secondary_contact = var.secondary_contact
  business_code     = var.business_code

}


######################
# Data sources
######################

data "google_secret_manager_secret" "gh_infra_token" {
  project   = var.secrets_project_id
  secret_id = var.gh_token_secret
}

######################
# IAM
######################

resource "google_project_iam_member" "service_catalog_tf_sa_roles" {
  for_each = toset(local.service_catalog_tf_sa_roles)
  project  = module.service_catalog_project.project_id
  role     = each.key
  member   = "serviceAccount:${var.app_infra_pipeline_service_accounts["service-catalog"]}"
}

// Service Agent for Secret Manager
resource "google_project_service_identity" "secretmanager_agent" {
  provider = google-beta
  project  = module.service_catalog_project.project_id
  service  = "secretmanager.googleapis.com"
}

// Service Agent for Storage service
resource "google_project_service_identity" "storage_agent" {
  provider = google-beta
  project  = module.service_catalog_project.project_id
  service  = "storage.googleapis.com"
}

// Service Agent for Storage service
resource "google_project_service_identity" "cloudbuild_agent" {
  provider = google-beta
  project  = module.service_catalog_project.project_id
  service  = "cloudbuild.googleapis.com"
}

module "service_catalog_project_kms" {
  source   = "../kms"
  for_each = toset(var.shared_kms_key_ring)

  app_infra_pipeline_service_account = var.app_infra_pipeline_service_accounts["service-catalog"]
  project_id                         = module.service_catalog_project.project_id
  key_ring                           = each.value
  name                               = module.service_catalog_project.project_id
  enable_cloudbuild_deploy           = true
  key_rotation_period                = var.key_rotation_period
  encrypter_decrypters = [
    "serviceAccount:${data.google_project.cloudbuild_project.number}@cloudbuild.gserviceaccount.com",
    "serviceAccount:${google_project_service_identity.cloudbuild_agent.email}",
    "serviceAccount:service-${module.service_catalog_project.project_number}@gs-project-accounts.iam.gserviceaccount.com",
    "serviceAccount:${google_project_service_identity.secretmanager_agent.email}"
  ]

  depends_on = [google_project_service_identity.cloudbuild_agent]
}

// Infra pipeline Cloud Build agent
data "google_project" "cloudbuild_project" {
  project_id = var.cloudbuild_project_id
}

resource "google_project_iam_member" "project_cloudbuild_admin" {
  project = module.service_catalog_project.project_id
  role    = "roles/cloudbuild.builds.editor"
  member  = "serviceAccount:${data.google_project.cloudbuild_project.number}@cloudbuild.gserviceaccount.com"
}

// Add Service Agent for Cloud Build
resource "google_project_iam_member" "cloudbuild_agent" {
  project = module.service_catalog_project.project_id
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${module.service_catalog_project.project_number}@cloudbuild.gserviceaccount.com"
}

resource "google_secret_manager_secret_iam_member" "service_catalog" {
  project   = var.secrets_project_id
  secret_id = data.google_secret_manager_secret.gh_infra_token.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${var.app_infra_pipeline_service_accounts["service-catalog"]}"
}

resource "google_secret_manager_secret_iam_member" "cloudbuild" {
  project   = var.secrets_project_id
  secret_id = data.google_secret_manager_secret.gh_infra_token.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${module.service_catalog_project.sa}"
}

resource "google_secret_manager_secret_iam_member" "cloudbuild_agent" {
  project   = var.secrets_project_id
  secret_id = data.google_secret_manager_secret.gh_infra_token.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:service-${module.service_catalog_project.project_number}@gcp-sa-cloudbuild.iam.gserviceaccount.com"
}

resource "google_secret_manager_secret_iam_member" "secrets_viewer" {
  project   = var.secrets_project_id
  secret_id = data.google_secret_manager_secret.gh_infra_token.secret_id
  role      = "roles/secretmanager.viewer"
  member    = "serviceAccount:${var.app_infra_pipeline_service_accounts["service-catalog"]}"
}

## project service account impersonation for cloud buils
resource "google_project_iam_member" "act_as" {
  project = module.service_catalog_project.project_id
  role    = "roles/iam.serviceAccountUser"
  member  = "serviceAccount:${var.app_infra_pipeline_service_accounts["service-catalog"]}"
}

resource "google_project_iam_member" "project_sa_roles" {
  for_each = toset(local.project_sa_roles)
  project  = module.service_catalog_project.project_id
  role     = each.key
  member   = "serviceAccount:${module.service_catalog_project.sa}"
}
