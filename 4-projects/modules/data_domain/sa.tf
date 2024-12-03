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

################################################
# Service Accounts for Data ingestion Project
################################################

locals {
  ingestion_service_accounts = {
    "sa-dataflow-controller"  = "Cloud Dataflow controller service account"
    "sa-storage-writer"       = "Cloud Storage data writer service account"
    "sa-pubsub-writer"        = "Cloud PubSub data writer service account"
    "sa-scheduler-controller" = "Cloud Scheduler controller service account"
  }

  confidential_service_accounts = {
    "sa-dataflow-controller-reid" = "Cloud Dataflow controller service account"
  }
}

// Ingestion project service accounts
resource "google_service_account" "ingestion_service_accounts" {
  for_each     = local.ingestion_service_accounts
  project      = module.ingestion_project.project_id
  account_id   = each.key
  display_name = each.value
}


// Confidential project service accounts
resource "google_service_account" "confidential_service_accounts" {
  for_each     = local.confidential_service_accounts
  project      = module.confidential_project.project_id
  account_id   = each.key
  display_name = each.value
}
