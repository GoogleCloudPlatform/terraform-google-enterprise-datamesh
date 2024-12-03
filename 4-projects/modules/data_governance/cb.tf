/**
 * Copyright 2021 Google LLC
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
  app_infra_pipeline_service_accounts = { "data-governance" = var.terraform_service_account }

  sa_roles = {
    "data-governance" = [
      "roles/bigquery.admin",
      "roles/cloudkms.admin",
      "roles/cloudkms.cryptoKeyEncrypter",
      "roles/cloudscheduler.admin",
      "roles/cloudfunctions.admin",
      "roles/cloudtasks.admin",
      "roles/dlp.admin",
      "roles/datacatalog.admin",
      "roles/firebase.admin",
      "roles/resourcemanager.projectIamAdmin",
      "roles/run.admin",
      "roles/secretmanager.admin",
      "roles/iam.serviceAccountAdmin",
      "roles/iam.serviceAccountTokenCreator",
      "roles/serviceusage.serviceUsageAdmin",
      "roles/storage.admin",
      "roles/workflows.admin",
      "roles/pubsub.admin",
    ]
  }

  source_repos = setintersection(
    toset(keys(local.app_infra_pipeline_service_accounts)),
    toset(keys(local.sa_roles))
  )
  pipeline_roles = flatten([
    for repo in local.source_repos : [
      for role in local.sa_roles[repo] :
      {
        repo = repo
        role = role
        sa   = local.app_infra_pipeline_service_accounts[repo]
      }
    ]
  ])

  network_user_role = flatten([
    for repo in local.source_repos : [
      for subnet in var.shared_vpc_subnets :
      {
        repo   = repo
        subnet = element(split("/", subnet), index(split("/", subnet), "subnetworks", ) + 1, )
        region = element(split("/", subnet), index(split("/", subnet), "regions") + 1, )
        sa     = local.app_infra_pipeline_service_accounts[repo]
      }
    ]
  ])
}

# Additional roles to the App Infra Pipeline service account
resource "google_project_iam_member" "app_infra_pipeline_sa_roles" {
  for_each = { for pr in local.pipeline_roles : "${pr.repo}-${pr.role}" => pr }

  project = module.data_governance_project.project_id
  role    = each.value.role
  member  = "serviceAccount:${each.value.sa}"
}

resource "google_folder_iam_member" "folder_network_viewer" {
  for_each = local.app_infra_pipeline_service_accounts

  folder = var.folder_id
  role   = "roles/compute.networkViewer"
  member = "serviceAccount:${each.value}"
}

resource "google_compute_subnetwork_iam_member" "service_account_role_to_vpc_subnets" {
  provider = google-beta
  for_each = { for nr in local.network_user_role : "${nr.repo}-${nr.subnet}" => nr }

  subnetwork = each.value.subnet
  role       = "roles/compute.networkUser"
  region     = each.value.region
  project    = var.shared_vpc_host_project_id
  member     = "serviceAccount:${each.value.sa}"
}
