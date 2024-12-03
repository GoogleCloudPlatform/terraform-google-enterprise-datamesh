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
  cloud_functions = distinct([
    for f in fileset("${path.module}/../../static_data", "cloud_functions/**") :
    split("/", f)[1]
  ])

  domains = distinct(flatten([
    for domain in var.dlp_job_inspect_datasets : [
      for function in local.cloud_functions :
      {
        domain   = domain.domain_name
        function = function
      }
    ]
  ]))

  bq_labels = {
    cdmc            = "remote_functions"
    data_governance = true
  }
}


######################################
# Development
######################################

module "bigquery_remote_functions_development" {
  source = "../../modules/bigquery"

  dataset_id                 = "remote_functions_dev"
  dataset_labels             = merge(local.bq_labels, { environment = "development" })
  dataset_name               = "remote_functions_dev"
  delete_contents_on_destroy = true
  encryption_key             = local.bq_data_quality_kms_key

  location   = var.region
  project_id = local.data_governance_project_id
}

resource "google_storage_bucket" "function_bucket_development" {
  project                     = local.data_governance_project_id
  name                        = "bkt-cloud-function-development-${local.data_governance_project_id}"
  location                    = var.region
  uniform_bucket_level_access = true
}

resource "google_bigquery_connection" "connection_development" {
  connection_id = "remote-connection-development"
  project       = local.data_governance_project_id
  location      = var.region
  cloud_resource {}
}

resource "google_bigquery_connection_iam_member" "connection_development" {
  connection_id = google_bigquery_connection.connection_development.connection_id
  project       = google_bigquery_connection.connection_development.project
  location      = google_bigquery_connection.connection_development.location
  role          = "roles/bigquery.connectionUser"
  member        = "serviceAccount:${local.data_governance_sa_tag_creator}"
}


module "cloud_function_development_non_confidential" {
  for_each = { for domain in local.domains : "${domain.domain}-${domain.function}" => domain }
  source   = "../../modules/cloud_function"

  bucket_name           = google_storage_bucket.function_bucket_development.name
  source_path           = "${path.module}/../../static_data/cloud_functions/${each.value.function}/function/${each.value.function}.zip"
  source_archive_object = "${each.value.function}.zip"

  region      = var.region
  domain_name = each.value.domain

  function_description        = "${each.value.function} Cloud Function"
  function_name               = "${each.value.function}_dev"
  service_account_email       = local.cloud_function_sa
  build_service_account_email = "projects/${local.data_governance_project_id}/serviceAccounts/${local.cloud_function_sa}"
  ingress_settings            = "ALLOW_INTERNAL_AND_GCLB"

  entry_point = each.value.function == "ultimate_source" ? "process_request" : "event_handler"
  environment_variables = {
    REGION          = var.region,
    PROJECT_ID_DATA = local.data_domain_non_conf_projects_dev[each.value.domain].project_id
    PROJECT_ID_GOV  = local.data_governance_project_id
  }

  project_id = local.data_governance_project_id

  invoker_member = google_bigquery_connection.connection_development.cloud_resource[0].service_account_id

  template_path          = "${path.module}/../../static_data/cloud_functions/${each.value.function}/sql"
  remote_connection_name = "remote-connection-development"
  dataset                = "remote_functions_dev"

  depends_on = [
    module.bigquery_remote_functions_development,
    google_storage_bucket.function_bucket_development,
    google_bigquery_connection.connection_development,
  ]
}


######################################
# Production
######################################

module "bigquery_remote_functions_production" {
  source = "../../modules/bigquery"

  dataset_id                 = "remote_functions_prod"
  dataset_labels             = merge(local.bq_labels, { environment = "production" })
  dataset_name               = "remote_functions_prod"
  delete_contents_on_destroy = true
  encryption_key             = local.bq_data_quality_kms_key

  location   = var.region
  project_id = local.data_governance_project_id
}

resource "google_storage_bucket" "function_bucket_production" {
  project                     = local.data_governance_project_id
  name                        = "bkt-cloud-function-production-${local.data_governance_project_id}"
  location                    = var.region
  uniform_bucket_level_access = true
}

resource "google_bigquery_connection" "connection_production" {
  connection_id = "remote-connection-production"
  project       = local.data_governance_project_id
  location      = var.region
  cloud_resource {}
}

resource "google_bigquery_connection_iam_member" "connection_production" {
  connection_id = google_bigquery_connection.connection_production.connection_id
  project       = google_bigquery_connection.connection_production.project
  location      = google_bigquery_connection.connection_production.location
  role          = "roles/bigquery.connectionUser"
  member        = "serviceAccount:${local.data_governance_sa_tag_creator}"
}

module "cloud_function_production_non_confidential" {
  for_each = { for domain in local.domains : "${domain.domain}-${domain.function}" => domain }
  source   = "../../modules/cloud_function"

  bucket_name           = google_storage_bucket.function_bucket_production.name
  source_path           = "${path.module}/../../static_data/cloud_functions/${each.value.function}/function/${each.value.function}.zip"
  source_archive_object = "${each.value.function}.zip"

  region      = var.region
  domain_name = each.value.domain

  function_description        = "${each.value.function} Cloud Function"
  function_name               = "${each.value.function}_prod"
  service_account_email       = local.cloud_function_sa
  build_service_account_email = "projects/${local.data_governance_project_id}/serviceAccounts/${local.cloud_function_sa}"
  ingress_settings            = "ALLOW_INTERNAL_AND_GCLB"

  entry_point = each.value.function == "ultimate_source" ? "process_request" : "event_handler"
  environment_variables = {
    REGION          = var.region,
    PROJECT_ID_DATA = local.data_domain_non_conf_projects_prod[each.value.domain].project_id
    PROJECT_ID_GOV  = local.data_governance_project_id
  }

  project_id = local.data_governance_project_id

  invoker_member = google_bigquery_connection.connection_production.cloud_resource[0].service_account_id

  template_path          = "${path.module}/../../static_data/cloud_functions/${each.value.function}/sql"
  remote_connection_name = "remote-connection-production"
  dataset                = "remote_functions_prod"

  depends_on = [
    module.bigquery_remote_functions_production,
    google_storage_bucket.function_bucket_production,
    google_bigquery_connection.connection_production,
  ]
}

######################################
# Non Production
######################################
module "bigquery_remote_functions_non_production" {
  source = "../../modules/bigquery"

  dataset_id                 = "remote_functions_nonp"
  dataset_labels             = merge(local.bq_labels, { environment = "non_production" })
  dataset_name               = "remote_functions_nonp"
  delete_contents_on_destroy = true
  encryption_key             = local.bq_data_quality_kms_key

  location   = var.region
  project_id = local.data_governance_project_id
}

resource "google_storage_bucket" "function_bucket_non_production" {
  project                     = local.data_governance_project_id
  name                        = "bkt-cloud-function-non-prod-${local.data_governance_project_id}"
  location                    = var.region
  uniform_bucket_level_access = true
}

resource "google_bigquery_connection" "connection_non_production" {
  connection_id = "remote-connection-non-production"
  project       = local.data_governance_project_id
  location      = var.region
  cloud_resource {}
}

resource "google_bigquery_connection_iam_member" "connection_non_production" {
  connection_id = google_bigquery_connection.connection_non_production.connection_id
  project       = google_bigquery_connection.connection_non_production.project
  location      = google_bigquery_connection.connection_non_production.location
  role          = "roles/bigquery.connectionUser"
  member        = "serviceAccount:${local.data_governance_sa_tag_creator}"
}

module "cloud_function_non_production_non_confidential" {
  for_each = { for domain in local.domains : "${domain.domain}-${domain.function}" => domain }
  source   = "../../modules/cloud_function"

  bucket_name           = google_storage_bucket.function_bucket_non_production.name
  source_path           = "${path.module}/../../static_data/cloud_functions/${each.value.function}/function/${each.value.function}.zip"
  source_archive_object = "${each.value.function}.zip"

  region      = var.region
  domain_name = each.value.domain

  function_description        = "${each.value.function} Cloud Function"
  function_name               = "${each.value.function}_nonp"
  service_account_email       = local.cloud_function_sa
  build_service_account_email = "projects/${local.data_governance_project_id}/serviceAccounts/${local.cloud_function_sa}"
  ingress_settings            = "ALLOW_INTERNAL_AND_GCLB"

  entry_point = each.value.function == "ultimate_source" ? "process_request" : "event_handler"
  environment_variables = {
    REGION          = var.region,
    PROJECT_ID_DATA = local.data_domain_non_conf_projects_nonp[each.value.domain].project_id
    PROJECT_ID_GOV  = local.data_governance_project_id
  }

  project_id = local.data_governance_project_id

  invoker_member = google_bigquery_connection.connection_non_production.cloud_resource[0].service_account_id

  template_path          = "${path.module}/../../static_data/cloud_functions/${each.value.function}/sql"
  remote_connection_name = "remote-connection-non-production"
  dataset                = "remote_functions_nonp"

  depends_on = [
    module.bigquery_remote_functions_non_production,
    google_storage_bucket.function_bucket_non_production,
    google_bigquery_connection.connection_non_production,
  ]
}

