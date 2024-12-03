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


module "record_manager_bucket" {
  source   = "../../modules/gcs_bucket"
  for_each = toset([var.record_manager_bucket_name, var.record_manager_config["archives_bucket"]])

  project_id = local.data_governance_project_id

  bucket_name     = each.key
  bucket_location = var.region
  storage_class   = var.bucket_storage_class

  uniform_bucket_level_access = true
  force_destroy               = true

  enable_versioning    = true
  default_kms_key_name = local.data_governance_kms_key
}

resource "google_storage_bucket_iam_member" "record_manager_bucket" {
  bucket = module.record_manager_bucket[var.record_manager_bucket_name].bucket.name
  role   = "roles/storage.legacyBucketReader"
  member = "serviceAccount:${local.record_manager_sa}"
}

resource "google_storage_bucket_iam_member" "record_manager_archives_bucket" {
  bucket = module.record_manager_bucket[var.record_manager_config["archives_bucket"]].bucket.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${local.record_manager_sa}"
}

resource "google_storage_bucket_iam_member" "record_manager_archives_bucket_connection" {
  bucket = module.record_manager_bucket[var.record_manager_config["archives_bucket"]].bucket.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_bigquery_connection.connection_development.cloud_resource[0].service_account_id}"
}

module "record_manager_development" {
  source   = "../../modules/record_manager"
  for_each = toset(distinct([for domain in var.dlp_job_inspect_datasets : domain.domain_name if domain.environment == "development"]))

  project_id                 = local.data_governance_project_id
  region                     = var.region
  environment                = "development"
  artifact_project_id        = local.artifact_project_id
  artifact_repository_folder = var.artifact_repository_folder
  artifact_repository_name   = var.artifact_repository_name

  cloud_run_service_account           = local.record_manager_sa
  data_domain_name                    = each.key
  non_production_project_id           = local.data_domain_non_conf_projects_dev[each.key].project_id
  record_manager_config_bucket        = module.record_manager_bucket[var.record_manager_bucket_name].bucket.name
  tag_engine_endpoint                 = module.tag_engine.cloud_run_service.uri
  remote_connection                   = google_bigquery_connection.connection_development.name
  record_manager_image_name           = var.record_manager_image_name
  record_manager_image_tag            = var.record_manager_image_tag
  record_manager_config               = merge(var.record_manager_config, { archives_bucket = module.record_manager_bucket[var.record_manager_config["archives_bucket"]].bucket.name })
  record_manager_config_template_file = "${path.module}/../../templates/record_manager/record_manager_config.json.tmpl"
  datasets_in_scope                   = [for dataset in var.dlp_job_inspect_datasets : dataset.inspection_dataset if dataset.domain_name == each.key]

  depends_on = [module.tag_engine, google_bigquery_connection.connection_development]
}


module "record_manager_nonproduction" {
  source   = "../../modules/record_manager"
  for_each = toset(distinct([for domain in var.dlp_job_inspect_datasets : domain.domain_name if domain.environment == "nonproduction"]))

  project_id                 = local.data_governance_project_id
  region                     = var.region
  environment                = "nonproduction"
  artifact_project_id        = local.artifact_project_id
  artifact_repository_folder = var.artifact_repository_folder
  artifact_repository_name   = var.artifact_repository_name

  cloud_run_service_account           = local.record_manager_sa
  data_domain_name                    = each.key
  non_production_project_id           = local.data_domain_non_conf_projects_dev[each.key].project_id
  record_manager_config_bucket        = module.record_manager_bucket[var.record_manager_bucket_name].bucket.name
  tag_engine_endpoint                 = module.tag_engine.cloud_run_service.uri
  remote_connection                   = google_bigquery_connection.connection_development.name
  record_manager_image_name           = var.record_manager_image_name
  record_manager_image_tag            = var.record_manager_image_tag
  record_manager_config               = merge(var.record_manager_config, { archives_bucket = module.record_manager_bucket[var.record_manager_config["archives_bucket"]].bucket.name })
  record_manager_config_template_file = "${path.module}/../../templates/record_manager/record_manager_config.json.tmpl"
  datasets_in_scope                   = [for dataset in var.dlp_job_inspect_datasets : dataset.inspection_dataset if dataset.domain_name == each.key]

  depends_on = [module.tag_engine, google_bigquery_connection.connection_development]
}

module "record_manager_production" {
  source   = "../../modules/record_manager"
  for_each = toset(distinct([for domain in var.dlp_job_inspect_datasets : domain.domain_name if domain.environment == "production"]))

  project_id                 = local.data_governance_project_id
  region                     = var.region
  environment                = "production"
  artifact_project_id        = local.artifact_project_id
  artifact_repository_folder = var.artifact_repository_folder
  artifact_repository_name   = var.artifact_repository_name

  cloud_run_service_account           = local.record_manager_sa
  data_domain_name                    = each.key
  non_production_project_id           = local.data_domain_non_conf_projects_dev[each.key].project_id
  record_manager_config_bucket        = module.record_manager_bucket[var.record_manager_bucket_name].bucket.name
  tag_engine_endpoint                 = module.tag_engine.cloud_run_service.uri
  remote_connection                   = google_bigquery_connection.connection_development.name
  record_manager_image_name           = var.record_manager_image_name
  record_manager_image_tag            = var.record_manager_image_tag
  record_manager_config               = merge(var.record_manager_config, { archives_bucket = module.record_manager_bucket[var.record_manager_config["archives_bucket"]].bucket.name })
  record_manager_config_template_file = "${path.module}/../../templates/record_manager/record_manager_config.json.tmpl"
  datasets_in_scope                   = [for dataset in var.dlp_job_inspect_datasets : dataset.inspection_dataset if dataset.domain_name == each.key]

  depends_on = [module.tag_engine, google_bigquery_connection.connection_development]
}

