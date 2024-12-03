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
# IAM
########################################

locals {
  project_iam_roles = merge(flatten([
    for sa, config in local.project_iam : [
      for role in config.roles : {
        "${sa}.${role}" = {
          member = config.member
          role   = role
        }
      }
    ]
  ])...)
  project_iam = {
    #data governance iam
    "compute" = {
      member = "serviceAccount:${data.google_compute_default_service_account.default.email}",
      roles = [
        "roles/logging.logWriter",
        "roles/bigquery.admin",
        "roles/serviceusage.serviceUsageConsumer",
      ]
    }
    "cloud_run" = {
      member = "serviceAccount:${google_service_account.cloud_run.email}",
      roles = [
        "roles/run.invoker",
        "roles/serviceusage.serviceUsageConsumer",
        "roles/logging.logWriter",
        "roles/bigquery.admin",
        "roles/workflows.invoker",
        "roles/cloudbuild.builds.editor",
        "roles/iam.serviceAccountTokenCreator",
      ]
    }
    "cloud_function" = {
      member = "serviceAccount:${google_service_account.cloud_function.email}",
      roles = [
        "roles/cloudbuild.builds.builder",
        "roles/logging.logWriter",
        "roles/cloudtasks.taskRunner",
      ]
    }
    "scheduler" = {
      member = "serviceAccount:${google_service_account.scheduler_controller_service_account.email}",
      roles = [
        "roles/cloudscheduler.serviceAgent",
      ]
    }
    "tag_engine" = {
      member = "serviceAccount:${google_service_account.tag_engine.email}",
      roles = [
        "roles/cloudtasks.enqueuer",
        "roles/datastore.user",
        "roles/datastore.indexAdmin",
        "roles/run.invoker",
        "roles/storage.objectViewer",
        "roles/logging.logWriter",
        "roles/artifactregistry.repoAdmin",
        "roles/iam.serviceAccountViewer",
      ]
    }
    "tag_creator" = {
      member = "serviceAccount:${google_service_account.tag_creator.email}",
      roles = [
        "roles/datacatalog.tagEditor",
        "roles/datacatalog.tagTemplateUser",
        "roles/datacatalog.tagTemplateViewer",
        "roles/datacatalog.viewer",
        "roles/bigquery.admin",
        "roles/bigquery.jobUser",
        "roles/bigquery.dataViewer",
        "roles/bigquery.user",
        "roles/bigquery.resourceViewer",
        "roles/storage.objectViewer",
        "roles/logging.viewer",
      ]
    }
    "record_manager" = {
      member = "serviceAccount:${google_service_account.record_manager_service_account.email}",
      roles = [
        "roles/storage.objectViewer",
        "roles/bigquery.jobUser",
        "roles/bigquery.dataOwner",
        "roles/bigquery.connectionAdmin",
        "roles/datacatalog.searchAdmin",
        "roles/datacatalog.tagTemplateViewer",
        "roles/run.invoker",
        "roles/logging.logWriter",
      ]
    }
    "report_engine" = {
      member = "serviceAccount:${google_service_account.report_engine_service_account.email}",
      roles = [
        "roles/bigquery.resourceViewer",
        "roles/bigquery.metadataViewer",
        "roles/datacatalog.viewer",
        "roles/datalineage.viewer",
        "roles/bigquery.dataEditor",
        "roles/bigquery.jobUser",
        "roles/pubsub.publisher",
        "roles/pubsub.viewer",
      ]
    }
    "pubsub" = {
      member = "serviceAccount:${google_project_service_identity.identity["pubsub.googleapis.com"].email}",
      roles = [
        "roles/bigquery.dataEditor",
        "roles/bigquery.metadataViewer",
      ]
    }
    "bigquerydatatransfer" = {
      member = "serviceAccount:${google_project_service_identity.identity["bigquerydatatransfer.googleapis.com"].email}",
      roles = [
        "roles/bigquery.admin" // roles/bigquerydatatransfer.serviceAgent is granted automatically
      ]
    }
    "dashboard" = {
      member = "serviceAccount:${google_service_account.dashboard_service_account.email}",
      roles = [
        "roles/bigquery.dataViewer",
        "roles/bigquery.jobUser",
        "roles/iam.serviceAccountTokenCreator",
      ]
    }
    "data_access_management" = {
      member = "serviceAccount:${google_service_account.data_access_management_service_account.email}",
      roles = [
        "roles/bigquery.dataEditor",
      ]
    }
  }

  dlp_kms_wrapper_roles = [
    "roles/secretmanager.secretAccessor",
    "roles/secretmanager.viewer",
  ]

  sa_tag_engine_users = {
    "cloud_run"  = google_service_account.cloud_run.email,
    "tag_engine" = google_service_account.tag_engine.email,
    "terraform"  = var.terraform_service_account,
  }

  sa_data_access_management_users = {
    "cloud_run"              = google_service_account.cloud_run.email,
    "data_access_management" = google_service_account.data_access_management_service_account.email,
    "terraform"              = var.terraform_service_account,
  }

  cloud_run_service_account_users = {
    "cloud_run" = google_service_account.cloud_run.email,
    "terraform" = var.terraform_service_account,
  }

  data_governance_sa_user = {
    "cloud_function"                 = google_service_account.cloud_function.id
    "report_engine_service_account"  = google_service_account.report_engine_service_account.id
    "record_manager_service_account" = google_service_account.record_manager_service_account.id
  }
}

data "google_compute_default_service_account" "default" {
  project = module.data_governance_project.project_id
}

resource "google_service_account_iam_member" "cloud_run" {
  for_each           = local.cloud_run_service_account_users
  service_account_id = google_service_account.cloud_run.id
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:${each.value}"
}

resource "google_service_account_iam_member" "tf_sa_data_governance" {
  for_each           = local.data_governance_sa_user
  service_account_id = each.value
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:${var.terraform_service_account}"
}


resource "google_service_account_iam_member" "cloud_function" {
  service_account_id = google_service_account.cloud_function.id
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:${var.terraform_service_account}"
}

# ************************************************************ #
# Create the service account policy bindings for tag_engine_sa
# ************************************************************ #

resource "google_service_account_iam_member" "serviceAccountUser_tag_engine_sa" {
  for_each           = local.sa_tag_engine_users
  service_account_id = google_service_account.tag_engine.id
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:${each.value}"
}

resource "google_service_account_iam_member" "serviceAccountUser_tag_creator_sa" {
  for_each           = local.sa_tag_engine_users
  service_account_id = google_service_account.tag_creator.id
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:${each.value}"
}

resource "google_service_account_iam_member" "serviceAccountViewer_tag_creator_sa" {
  service_account_id = google_service_account.tag_creator.id
  role               = "roles/iam.serviceAccountViewer"
  member             = "serviceAccount:${google_service_account.tag_engine.email}"
}

resource "google_service_account_iam_member" "serviceAccountTokenCreator_tag_creator_sa" {
  service_account_id = google_service_account.tag_creator.id
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = "serviceAccount:${google_service_account.tag_engine.email}"
}

resource "google_service_account_iam_member" "serviceAccountUser_compute_sa" {
  service_account_id = "projects/${module.data_governance_project.project_id}/serviceAccounts/${data.google_compute_default_service_account.default.email}"
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:${var.terraform_service_account}"
}

# ************************************************************ #
# Create the service account policy bindings for data access management
# ************************************************************ #

resource "google_service_account_iam_member" "serviceAccountUser_data_access_management_sa" {
  for_each           = local.sa_data_access_management_users
  service_account_id = google_service_account.data_access_management_service_account.id
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:${each.value}"
}


# ************************************************************************ #
# Consolidated Resources - Secret Manager IAM
# ************************************************************************ #

resource "google_secret_manager_secret_iam_member" "dlp_kms_wrapper" {
  for_each  = toset(local.dlp_kms_wrapper_roles)
  project   = var.secrets_project_id
  member    = "serviceAccount:${var.terraform_service_account}"
  role      = each.value
  secret_id = data.google_secret_manager_secret.dlp_kms_wrapper.secret_id
}

# ************************************************************************ #
# Consolidated Resources - Project IAM
# ************************************************************************ #
resource "google_project_iam_member" "data_governance_project_iam" {
  for_each = local.project_iam_roles
  project  = module.data_governance_project.project_id
  role     = each.value.role
  member   = each.value.member
}

resource "google_project_iam_member" "kms_viewer" {
  project = var.kms_project_id # one instance of unique project, so it's kept out of loop
  role    = "roles/cloudkms.viewer"
  member  = "serviceAccount:${google_service_account.cloud_function.email}"
}

resource "google_project_iam_member" "kms_encrypter" {
  project = var.kms_project_id # one instance of unique project, so it's kept out of loop
  role    = "roles/cloudkms.cryptoKeyDecrypterViaDelegation"
  member  = "group:${var.encrypted_data_viewers_group}"
}
