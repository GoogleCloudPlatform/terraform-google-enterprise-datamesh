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
  default_ingestion_apis = [
    "accesscontextmanager.googleapis.com",
    "appengine.googleapis.com",
    "artifactregistry.googleapis.com",
    "bigquery.googleapis.com",
    "cloudbilling.googleapis.com",
    "cloudbuild.googleapis.com",
    "cloudkms.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "cloudscheduler.googleapis.com",
    "compute.googleapis.com",
    "datacatalog.googleapis.com",
    "dataflow.googleapis.com",
    "dataform.googleapis.com",
    "datapipelines.googleapis.com",
    "dlp.googleapis.com",
    "dns.googleapis.com",
    "iam.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "pubsub.googleapis.com",
    "serviceusage.googleapis.com",
    "storage-api.googleapis.com",
  ]

  default_non_confidential_apis = [
    "accesscontextmanager.googleapis.com",
    "bigquery.googleapis.com",
    "cloudbilling.googleapis.com",
    "cloudbuild.googleapis.com",
    "cloudkms.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "datacatalog.googleapis.com",
    "iam.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "pubsub.googleapis.com",
    "serviceusage.googleapis.com",
    "storage-api.googleapis.com",
    "storage.googleapis.com",
    "orgpolicy.googleapis.com",
  ]

  default_confidential_apis = [
    "accesscontextmanager.googleapis.com",
    "artifactregistry.googleapis.com",
    "bigquery.googleapis.com",
    "cloudbilling.googleapis.com",
    "cloudbuild.googleapis.com",
    "cloudkms.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "compute.googleapis.com",
    "datacatalog.googleapis.com",
    "dataflow.googleapis.com",
    "dataform.googleapis.com",
    "datapipelines.googleapis.com",
    "dlp.googleapis.com",
    "dns.googleapis.com",
    "iam.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "serviceusage.googleapis.com",
    "storage-api.googleapis.com",
    "orgpolicy.googleapis.com",
  ]

  ingestion_service_identities_apis = [
    "dataflow.googleapis.com",
    "pubsub.googleapis.com",
    "storage.googleapis.com",
    "cloudbuild.googleapis.com",
  ]

  nonconfidential_service_identities_apis = [
    "dataflow.googleapis.com",
    "pubsub.googleapis.com",
    "storage.googleapis.com",
    "cloudbuild.googleapis.com",
  ]

  confidential_service_identities_apis = [
    "dataflow.googleapis.com",
  ]
}

module "ingestion_project" {
  source = "../single_project"

  org_id          = local.org_id
  billing_account = local.billing_account
  folder_id       = var.folder_name
  environment     = var.env
  project_budget  = var.project_budget
  project_prefix  = local.project_prefix
  vpc             = "restricted"

  shared_vpc_host_project_id = local.restricted_host_project_id
  shared_vpc_subnets         = local.restricted_subnets_self_links

  enable_cloudbuild_deploy            = true
  app_infra_pipeline_service_accounts = local.app_infra_pipeline_service_accounts


  # Metadata
  project_suffix    = "${var.data_domain.name}-ngst"
  application_name  = "${var.business_code}-${var.data_domain.name}-ingestion"
  billing_code      = "1234"
  primary_contact   = "example@example.com"
  secondary_contact = "example2@example.com"
  business_code     = var.business_code
  activate_apis     = concat(local.default_ingestion_apis, var.data_domain.ingestion_apis)


  sa_roles = {
    "${var.data_domain.name}-ingest" = [
      "roles/cloudscheduler.admin",
      "roles/compute.networkAdmin",
      "roles/compute.securityAdmin",
      "roles/dataflow.developer",
      "roles/dns.admin",
      "roles/resourcemanager.projectIamAdmin",
      "roles/iam.serviceAccountAdmin",
      "roles/iam.serviceAccountTokenCreator",
      "roles/serviceusage.serviceUsageAdmin",
      "roles/storage.admin",
      "roles/pubsub.admin",
      "roles/logging.admin",
    ]
  }

  vpc_service_control_attach_enabled = "true"
  vpc_service_control_perimeter_name = "accessPolicies/${local.access_context_manager_policy_id}/servicePerimeters/${local.perimeter_name}"
  vpc_service_control_sleep_duration = "60s"
}

module "nonconfidential_project" {
  source = "../single_project"

  org_id                     = local.org_id
  billing_account            = local.billing_account
  folder_id                  = var.folder_name
  environment                = var.env
  vpc                        = "restricted"
  shared_vpc_host_project_id = local.restricted_host_project_id
  shared_vpc_subnets         = local.restricted_subnets_self_links
  project_budget             = var.project_budget
  project_prefix             = local.project_prefix

  enable_cloudbuild_deploy            = true
  app_infra_pipeline_service_accounts = local.app_infra_pipeline_service_accounts

  # Metadata
  project_suffix    = "${var.data_domain.name}-ncnf"
  application_name  = "${var.business_code}-${var.data_domain.name}-non-conf"
  billing_code      = "1234"
  primary_contact   = "example@example.com"
  secondary_contact = "example2@example.com"
  business_code     = var.business_code
  activate_apis     = concat(local.default_non_confidential_apis, var.data_domain.nonconfidential_apis)


  sa_roles = {
    "${var.data_domain.name}-non-conf" = [
      "roles/bigquery.admin",
      "roles/resourcemanager.projectIamAdmin",
      "roles/iam.serviceAccountAdmin",
      "roles/iam.serviceAccountTokenCreator",
      "roles/serviceusage.serviceUsageAdmin",
      "roles/storage.admin",
    ]
  }

  vpc_service_control_attach_enabled = "true"
  vpc_service_control_perimeter_name = "accessPolicies/${local.access_context_manager_policy_id}/servicePerimeters/${local.perimeter_name}"
  vpc_service_control_sleep_duration = "60s"
}

module "confidential_project" {
  source = "../single_project"

  org_id                     = local.org_id
  billing_account            = local.billing_account
  folder_id                  = var.folder_name
  environment                = var.env
  vpc                        = "restricted"
  shared_vpc_host_project_id = local.restricted_host_project_id
  shared_vpc_subnets         = local.restricted_subnets_self_links
  project_budget             = var.project_budget
  project_prefix             = local.project_prefix

  enable_cloudbuild_deploy            = true
  app_infra_pipeline_service_accounts = local.app_infra_pipeline_service_accounts

  # Metadata
  project_suffix    = "${var.data_domain.name}-cnf"
  application_name  = "${var.business_code}-${var.data_domain.name}-conf"
  billing_code      = "1234"
  primary_contact   = "example@example.com"
  secondary_contact = "example2@example.com"
  business_code     = var.business_code
  activate_apis     = concat(local.default_confidential_apis, var.data_domain.confidential_apis)

  sa_roles = {
    "${var.data_domain.name}-conf" = [
      "roles/bigquery.admin",
      "roles/compute.networkAdmin",
      "roles/compute.securityAdmin",
      "roles/dns.admin",
      "roles/dataflow.developer",
      "roles/resourcemanager.projectIamAdmin",
      "roles/iam.serviceAccountAdmin",
      "roles/iam.serviceAccountTokenCreator",
      "roles/serviceusage.serviceUsageAdmin",
      "roles/storage.admin",

    ]
  }

  vpc_service_control_attach_enabled = "true"
  vpc_service_control_perimeter_name = "accessPolicies/${local.access_context_manager_policy_id}/servicePerimeters/${local.perimeter_name}"
  vpc_service_control_sleep_duration = "60s"
}

#################################
# Service Agents
#################################

resource "google_project_service_identity" "ingestion" {
  for_each = toset(local.ingestion_service_identities_apis)
  provider = google-beta

  project = module.ingestion_project.project_id
  service = each.value
}

resource "google_project_service_identity" "nonconfidential" {
  for_each = toset(local.nonconfidential_service_identities_apis)
  provider = google-beta

  project = module.nonconfidential_project.project_id
  service = each.value
}

resource "google_project_service_identity" "confidential" {
  for_each = toset(local.confidential_service_identities_apis)
  provider = google-beta

  project = module.confidential_project.project_id
  service = each.value
}
