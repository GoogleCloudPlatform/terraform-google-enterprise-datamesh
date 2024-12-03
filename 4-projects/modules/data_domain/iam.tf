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
  project_iam_roles = merge(flatten([
    for sa, config in local.project_iam : [
      for role in config.roles : {
        "${sa}.${role}" = {
          member  = config.member
          role    = role
          project = config.project
        }
      }
    ]
  ])...)
  project_iam = {
    # data ingestion iam
    "ngst-compute" = {
      member = "serviceAccount:${local.data_governance_project_number}-compute@developer.gserviceaccount.com",
      roles = [
        "roles/bigquery.user",
        "roles/bigquery.dataViewer"
      ],
      project = module.ingestion_project.project_id
    }
    "ngst-dlp-api" = {
      member = "serviceAccount:service-${local.data_governance_project_number}@dlp-api.iam.gserviceaccount.com",
      roles = [
        "roles/bigquery.admin"
      ],
      project = module.ingestion_project.project_id
    }
    "ngst-dataflow-controller-reid" = {
      member  = "serviceAccount:${google_service_account.ingestion_service_accounts["sa-dataflow-controller"].email}",
      roles   = distinct(concat(local.additional_project_roles, local.default_data_ingestion_project_roles)),
      project = module.ingestion_project.project_id
    }
    "ngst-pubsub-writer" = {
      member  = "serviceAccount:${google_service_account.ingestion_service_accounts["sa-pubsub-writer"].email}",
      roles   = distinct(concat(local.additional_project_roles, local.default_data_ingestion_project_roles)),
      project = module.ingestion_project.project_id
    }

    # non confidential iam
    "ncnf-report-engine" = {
      member = "serviceAccount:${local.data_governance_sa_report_engine}",
      roles = [
        "roles/bigquery.jobUser",
        "roles/bigquery.dataViewer",
      ]
      project = module.nonconfidential_project.project_id
    }
    "ncnf-record-manager" = {
      member = "serviceAccount:${local.data_governance_sa_record_manager}",
      roles = [
        "roles/datacatalog.searchAdmin",
        "roles/datacatalog.entryViewer",
        "roles/bigquery.dataEditor",
      ]
      project = module.nonconfidential_project.project_id
    }
    "ncnf-dataflow-controller-reid" = {
      member  = "serviceAccount:${google_service_account.confidential_service_accounts["sa-dataflow-controller-reid"].email}",
      roles   = toset(local.nonconfidential_data_project_roles),
      project = module.nonconfidential_project.project_id
    }
    "ncnf-dataflow-controller" = {
      member  = "serviceAccount:${google_service_account.ingestion_service_accounts["sa-dataflow-controller"].email}",
      roles   = toset(local.nonconfidential_data_project_roles),
      project = module.nonconfidential_project.project_id
    }
    "ncnf-tf-injest-sa" = {
      member = "serviceAccount:${local.app_infra_pipeline_service_accounts["${var.data_domain.name}-ingest"]}",
      roles = [
        "roles/resourcemanager.projectIamAdmin",
        "roles/bigquery.admin",
      ]
      project = module.nonconfidential_project.project_id
    }
    "ncnf-cloud-run" = {
      member  = "serviceAccount:${local.data_governance_sa_cloud_run}",
      roles   = toset(local.nonconfidential_data_project_roles),
      project = module.nonconfidential_project.project_id
    }
    "ncnf-cloud-function" = {
      member  = "serviceAccount:${local.data_governance_sa_cloud_function}",
      roles   = toset(local.cloud_function_project_roles),
      project = module.nonconfidential_project.project_id
    }
    "ncnf-tag-creator" = {
      member  = "serviceAccount:${local.data_governance_sa_tag_creator}",
      roles   = toset(local.nonconfidential_tag_creator_project_roles),
      project = module.nonconfidential_project.project_id
    }
    "ncnf-dlp-api" = {
      member  = "serviceAccount:service-${local.data_governance_project_number}@dlp-api.iam.gserviceaccount.com",
      roles   = ["roles/bigquery.admin"],
      project = module.nonconfidential_project.project_id
    }
    "ncnf-data-viewer" = {
      member = "group:${var.non_confidential_consumers_viewers_group_email}",
      roles = [
        "roles/bigquery.dataViewer",
        "roles/bigquery.jobUser",
      ],
      project = module.nonconfidential_project.project_id
    }
    "ncnf-fine-grained-data-viewer" = {
      member  = "group:${var.non_confidential_fine_grained_data_viewer}",
      roles   = ["roles/datacatalog.categoryFineGrainedReader"],
      project = module.nonconfidential_project.project_id
    }
    "ncnf-encrypted-data-viewer" = {
      member  = "group:${var.non_confidential_encrypted_data_viewer}",
      roles   = ["roles/cloudkms.cryptoKeyDecrypterViaDelegation"],
      project = module.nonconfidential_project.project_id
    }
    "ncnf-masked-data-viewer" = {
      member  = "group:${var.non_confidential_masked_data_viewer}",
      roles   = ["roles/bigquerydatapolicy.maskedReader"],
      project = module.nonconfidential_project.project_id
    }

    #confidential iam
    "cnf-dataflow-controller-reid" = {
      member  = "serviceAccount:${google_service_account.confidential_service_accounts["sa-dataflow-controller-reid"].email}",
      roles   = toset(local.confidential_project_roles),
      project = module.confidential_project.project_id
    }
    "cnf-cloud-function" = {
      member  = "serviceAccount:${local.data_governance_sa_cloud_function}",
      roles   = toset(local.cloud_function_project_roles),
      project = module.confidential_project.project_id
    }
    "cnf-data-viewer" = {
      member = "group:${var.confidential_consumers_viewers_group_email}",
      roles = [
        "roles/bigquery.dataViewer",
        "roles/bigquery.jobUser",
      ],
      project = module.confidential_project.project_id
    }
    #artifacts iam
    "artifact-storage-admin" = {
      member  = "serviceAccount:${local.app_infra_pipeline_service_accounts["${var.data_domain.name}-ingest"]}",
      roles   = ["roles/storage.admin"],
      project = local.app_infra_artifacts_project_id
    }
    "artifact-cnf-storage-admin" = {
      member  = "serviceAccount:${local.app_infra_pipeline_service_accounts["${var.data_domain.name}-conf"]}",
      roles   = ["roles/storage.admin"],
      project = local.app_infra_artifacts_project_id
    }
    "artifact-dataflow-sa" = {
      member  = "serviceAccount:${google_service_account.confidential_service_accounts["sa-dataflow-controller-reid"].email}",
      roles   = toset(local.artifacts_project_roles),
      project = local.app_infra_artifacts_project_id
    }
    "artifacts-cnf-dataflow-sa" = {
      member  = "serviceAccount:${google_service_account.confidential_service_accounts["sa-dataflow-controller-reid"].email}",
      roles   = toset(local.artifacts_project_roles),
      project = local.app_infra_artifacts_project_id
    }
    #governance iam
    "governance-dataflow-sa" = {
      member  = "serviceAccount:${google_service_account.ingestion_service_accounts["sa-dataflow-controller"].email}",
      roles   = toset(local.governance_project_roles),
      project = local.data_governance_project_id
    }
    "governance-dataflow-reid-sa" = {
      member  = "serviceAccount:${google_service_account.confidential_service_accounts["sa-dataflow-controller-reid"].email}",
      roles   = toset(local.governance_project_roles),
      project = local.data_governance_project_id
    }
    "governance-ncf-prj-sa" = {
      member = "serviceAccount:${module.nonconfidential_project.sa}",
      roles = [
        "roles/datacatalog.viewer",
      ]
      project = local.data_governance_project_id
    }

    # service catalog
    "ngst-service-catalog" = {
      member = "serviceAccount:${module.ingestion_project.sa}",
      roles = [
        "roles/logging.logWriter",
        "roles/storage.admin",
        "roles/bigquery.admin",
        "roles/cloudkms.admin",
        "roles/dataflow.admin",
        "roles/pubsub.admin",
        "roles/secretmanager.secretAccessor",
        "roles/serviceusage.serviceUsageConsumer",
      ]
      project = module.ingestion_project.project_id
    }
    "ncnf-service-catalog" = {
      member = "serviceAccount:${module.nonconfidential_project.sa}",
      roles = [
        "roles/logging.logWriter",
        "roles/storage.admin",
        "roles/bigquery.admin",
      ]
      project = module.nonconfidential_project.project_id
    }

    "ngst-cloud-build" = {
      member = "serviceAccount:${module.ingestion_project.project_number}@cloudbuild.gserviceaccount.com",
      roles = [
        "roles/logging.logWriter",
        "roles/storage.admin",
      ]
      project = module.ingestion_project.project_id
    }
    "ncnf-cloud-build" = {
      member = "serviceAccount:${module.nonconfidential_project.project_number}@cloudbuild.gserviceaccount.com",
      roles = [
        "roles/logging.logWriter",
        "roles/storage.admin",
      ]
      project = module.nonconfidential_project.project_id
    }
  }

  default_data_ingestion_project_roles = [
    "roles/pubsub.subscriber",
    "roles/pubsub.editor",
    "roles/storage.objectViewer",
    "roles/dataflow.worker",
    "roles/compute.admin",
    "roles/storage.admin",
    "roles/monitoring.metricWriter",
    "roles/serviceusage.serviceUsageConsumer"
  ]

  bigquery_read_roles = [
    "roles/bigquery.jobUser",
    "roles/bigquery.dataEditor",
    "roles/serviceusage.serviceUsageConsumer"
  ]

  additional_project_roles = var.enable_bigquery_read_roles ? local.bigquery_read_roles : []

  # data_ingestion_project_roles = distinct(concat(local.additional_project_roles, local.default_data_ingestion_project_roles))

  governance_project_roles = [
    "roles/dlp.user",
    "roles/dlp.inspectTemplatesReader",
    "roles/dlp.deidentifyTemplatesReader",
  ]

  # governance_project_roles_confidential = [
  #   "roles/dlp.user",
  #   "roles/dlp.inspectTemplatesReader",
  #   "roles/dlp.deidentifyTemplatesReader"
  # ]

  nonconfidential_data_project_roles = [
    "roles/bigquery.dataEditor",
    "roles/bigquery.jobUser"
  ]

  nonconfidential_tag_creator_project_roles = [
    "roles/bigquery.dataOwner",
    "roles/cloudkms.viewer",
    "roles/datalineage.viewer",
    "roles/bigquery.metadataViewer",
    "roles/bigquery.dataEditor",
    "roles/bigquery.resourceViewer",
  ]

  cloud_function_project_roles = [
    "roles/bigquery.dataViewer",
    "roles/bigquery.jobUser",
    "roles/orgpolicy.policyViewer",
    "roles/datalineage.viewer",
  ]

  # nonconfidential_project_roles_confidential = [
  #   "roles/bigquery.dataViewer",
  #   "roles/bigquery.jobUser",
  # ]

  confidential_project_roles = [
    "roles/compute.admin",
    "roles/bigquery.dataEditor",
    "roles/bigquery.jobUser",
    "roles/dataflow.worker",
    "roles/storage.admin",
    "roles/storage.objectAdmin",
    "roles/serviceusage.serviceUsageConsumer",
  ]

  artifacts_project_roles = [
    "roles/artifactregistry.repoAdmin",
    "roles/artifactregistry.reader"
  ]

  secret_manager_access_sas = {
    "ingestion"        = "serviceAccount:${local.app_infra_pipeline_service_accounts["${var.data_domain.name}-ingest"]}",
    "confidential"     = "serviceAccount:${local.app_infra_pipeline_service_accounts["${var.data_domain.name}-conf"]}",
    "reidentification" = "serviceAccount:${google_service_account.confidential_service_accounts["sa-dataflow-controller-reid"].email}",
    "identification"   = "serviceAccount:${google_service_account.ingestion_service_accounts["sa-dataflow-controller"].email}",
  }

  all_projects = {
    "ingestion"       = module.ingestion_project,
    "confidential"    = module.confidential_project,
    "nonconfidential" = module.nonconfidential_project,
  }

  data_governance_state_bucket_access = {
    "ingestion"       = "serviceAccount:${local.app_infra_pipeline_service_accounts["${var.data_domain.name}-ingest"]}",
    "nonconfidential" = "serviceAccount:${local.app_infra_pipeline_service_accounts["${var.data_domain.name}-non-conf"]}",
    "confidential"    = "serviceAccount:${local.app_infra_pipeline_service_accounts["${var.data_domain.name}-conf"]}",
  }
}

########################################
# # Data ingestion project
########################################

resource "google_project_iam_member" "data_ingestion_project_iam" {
  for_each = local.project_iam_roles
  project  = each.value.project
  role     = each.value.role
  member   = each.value.member
}

resource "google_service_account_iam_member" "project_sa_user_ingest" {
  service_account_id = google_service_account.ingestion_service_accounts["sa-dataflow-controller"].name
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:${module.ingestion_project.sa}"
}

resource "google_service_account_iam_member" "terraform_sa_user_ingest" {
  service_account_id = google_service_account.ingestion_service_accounts["sa-dataflow-controller"].name
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:${local.app_infra_pipeline_service_accounts["${var.data_domain.name}-ingest"]}"
}

resource "google_service_account_iam_member" "terraform_sa_service_account_user_confidential" {
  service_account_id = google_service_account.confidential_service_accounts["sa-dataflow-controller-reid"].name
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:${module.confidential_project.sa}"
}

resource "google_service_account_iam_member" "project_sa_user_confidential" {
  service_account_id = google_service_account.confidential_service_accounts["sa-dataflow-controller-reid"].name
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:${module.confidential_project.sa}"
}

resource "google_service_account_iam_member" "terraform_sa_user_confidential" {
  service_account_id = google_service_account.confidential_service_accounts["sa-dataflow-controller-reid"].name
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:${local.app_infra_pipeline_service_accounts["${var.data_domain.name}-conf"]}"
}


########################################
# IAM for Governance Project
########################################
// State bucket access

resource "google_storage_bucket_iam_member" "data_governance_state_bucket" {
  for_each = local.data_governance_state_bucket_access
  bucket   = local.data_governance_tf_state_bucket
  role     = "roles/storage.objectViewer"
  member   = each.value
}

########################################
# IAM for Common Secret Access
########################################

data "google_secret_manager_secret" "kms_wrapper" {
  project   = local.common_secrets_project_id
  secret_id = local.kms_wrapper_secret_name
}

resource "google_secret_manager_secret_iam_member" "kms_wrapper_secret_viewer" {
  for_each  = local.secret_manager_access_sas
  project   = local.common_secrets_project_id
  secret_id = data.google_secret_manager_secret.kms_wrapper.secret_id
  role      = "roles/secretmanager.viewer"
  member    = each.value
}

resource "google_secret_manager_secret_iam_member" "kms_wrapper_secret" {
  for_each  = local.secret_manager_access_sas
  project   = local.common_secrets_project_id
  secret_id = data.google_secret_manager_secret.kms_wrapper.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = each.value
}

#################################
# Logging project access
#################################

resource "google_project_iam_member" "log_browser" {
  for_each = local.all_projects
  project  = local.common_logs_project_id
  role     = "roles/browser"
  member   = "serviceAccount:${each.value.sa}"
}

resource "google_project_iam_member" "logs_writer" {
  for_each = local.all_projects
  project  = local.common_logs_project_id
  role     = "roles/logging.logWriter"
  member   = "serviceAccount:${each.value.sa}"
}

#################################
# KMS project access
#################################

resource "google_project_iam_member" "kms_browser" {
  for_each = local.all_projects
  project  = local.shared_kms_project_id
  role     = "roles/browser"
  member   = "serviceAccount:${each.value.sa}"
}

resource "google_project_iam_member" "kms_viewer" {
  for_each = local.all_projects
  project  = local.shared_kms_project_id
  role     = "roles/cloudkms.viewer"
  member   = "serviceAccount:${each.value.sa}"
}

##################################
# Common logs bucket access
##################################

// Grant objectCreator role on the common log bucket to the Storage service agent
resource "google_storage_bucket_iam_member" "storage_log_writer" {
  bucket = local.logs_export_storage_bucket_name
  role   = "roles/storage.objectCreator"
  member = "serviceAccount:service-${module.ingestion_project.project_number}@gs-project-accounts.iam.gserviceaccount.com"

  depends_on = [
    time_sleep.wait_for_sa
  ]
}
