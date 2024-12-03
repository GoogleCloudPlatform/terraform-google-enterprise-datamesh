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

########################################
# Service Accounts
########################################

resource "google_service_account" "tag_creator" {
  project      = module.data_governance_project.project_id
  account_id   = var.tag_creator_service_account_id
  display_name = "Tag Engine Creator SA to create tags in data catalog"
  description  = "Service account to manage tagging"
}

resource "google_service_account" "tag_engine" {
  project      = module.data_governance_project.project_id
  account_id   = var.tag_engine_service_account_id
  display_name = "Tag Engine SA"
  description  = "Service account for running the tag engine cloud run service"
}

resource "google_service_account" "cloud_run" {
  project      = module.data_governance_project.project_id
  account_id   = var.cloud_run_service_acount_id
  display_name = "Cloud Run SA"
  description  = "Service account to manage Cloud Run"
}

resource "google_service_account" "report_engine_service_account" {
  project      = module.data_governance_project.project_id
  account_id   = var.report_engine_service_account_id
  display_name = "Report Engine SA"
  description  = "Service account for managing report engine"
}

resource "google_service_account" "cloud_function" {
  project      = module.data_governance_project.project_id
  account_id   = var.cloud_function_service_acount_id
  display_name = "Cloud Function SA"
  description  = "Service account to manage Cloud Functions"
}
resource "google_service_account" "scheduler_controller_service_account" {
  project      = module.data_governance_project.project_id
  account_id   = var.scheduler_controller_service_account_id
  display_name = "Scheduler Controller SA"
  description  = "Service account to manage scheduler controller"
}
data "google_bigquery_default_service_account" "bq_sa" {
  project = module.data_governance_project.project_id
}

resource "google_project_service_identity" "firestore" {
  provider = google-beta

  project = module.data_governance_project.project_id
  service = "firestore.googleapis.com"
}

resource "google_project_service_identity" "pubsub" {
  provider = google-beta

  project = module.data_governance_project.project_id
  service = "pubsub.googleapis.com"
}


# ********************************************************************** #
# Create the service account & custom role record manager / report_engine
# ********************************************************************** #

resource "google_service_account" "record_manager_service_account" {
  project      = module.data_governance_project.project_id
  account_id   = var.record_manager_service_account_id
  display_name = "Record Manager SA"
  description  = "Service account for managing record services"
}

# ********************************************************************** #
# Create the service account & custom role data access management
# ********************************************************************** #

resource "google_service_account" "data_access_management_service_account" {
  project      = module.data_governance_project.project_id
  account_id   = var.data_access_management_service_account_id
  display_name = "Data Access Manager SA"
  description  = "Service account for managing dataset access"
}

# ********************************************************************** #
# Create the service account & custom role looker dashboard
# ********************************************************************** #

resource "google_service_account" "dashboard_service_account" {
  project      = module.data_governance_project.project_id
  account_id   = var.dashboard_service_account_id
  display_name = "Data Access Manager SA"
  description  = "Service account for managing dataset access"
}
