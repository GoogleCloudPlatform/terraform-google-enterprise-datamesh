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

module "dataflow_bucket" {
  source = "../bucket"

  project_id        = local.data_domain_confidential_project
  name              = "tmp-dataflow"
  add_random_suffix = true
  domain_name       = var.domain_name
  business_code     = var.business_code
  environment       = var.env
  environment_code  = var.env_code
  storage_class     = "STANDARD"
  log_bucket_name   = local.logging_bucket_name
  kms_project_id    = local.kms_project_id

  force_destroy = false
}

module "bigquery" {
  source   = "../bigquery"
  for_each = toset([for dataset in var.confidential_datasets : dataset.name])

  project_id   = local.data_domain_confidential_project
  dataset_id   = "${var.business_code}_${var.bigquery_dataset_id_prefix}_${each.key}_${var.env}"
  dataset_name = var.bigquery_dataset_name
  description  = var.bigquery_description
  tables       = var.bigquery_tables
  location     = var.bigquery_location

  external_tables = var.bigquery_external_tables

  delete_contents_on_destroy = var.bigquery_delete_contents_on_destroy
  deletion_protection        = var.bigquery_deletion_protection

  default_table_expiration_ms = var.bigquery_default_table_expiration_ms
  max_time_travel_hours       = var.bigquery_max_time_travel_hours

  encryption_key = local.bigquery_key_name

  access             = var.bigquery_access
  views              = var.bigquery_views
  materialized_views = var.biugquery_materialized_views

  routines = var.bigquery_routines

  dataset_labels = merge({
    environment   = var.env
    domain        = var.domain_name
    business_unit = var.business_unit
  }, var.additional_bigquery_dataset_labels)
}

module "dataflow_flex_job_bq_to_bq" {
  source = "../dataflow_flex_job"
  for_each = { for item in flatten([
    for dataset in var.confidential_datasets : [
      for table_name, schema in dataset.tables_schema : {
        dataset_name = dataset.name
        table_name   = table_name
        schema       = schema
      }
    ]
  ]) : "${item.dataset_name}.${item.table_name}" => item }

  project_id     = local.data_domain_confidential_project
  kms_project_id = local.kms_project_id
  name           = "dataflow-flex-job-bq-to-bq-${lower(replace(replace(each.value.table_name, "_", "-"), ".", "-"))}-${var.env}"
  keyring_name   = var.keyring_name

  region                  = var.region
  network                 = local.restricted_network_name
  subnetworks             = local.restricted_subnets_names
  dataflow_gcs_bucket_url = var.dataflow_gcs_bucket_url
  network_project_id      = local.restricted_host_project_id
  service_account_email   = local.dataflow_controller_service_account
  business_code           = var.business_code
  environment             = var.env
  domain_name             = var.domain_name
  enable_streaming_engine = true
  max_workers             = 10
  ip_configuration        = "WORKER_IP_PRIVATE"
  template_filename       = var.dataflow_template_jobs["bq_to_bq"]["template_filename"]
  temp_location           = "gs://${module.dataflow_bucket.storage_bucket.name}/temp/"
  staging_location        = "gs://${module.dataflow_bucket.storage_bucket.name}/staging/"
  sdk_container_image     = "${var.region}-docker.pkg.dev/${local.app_infra_artifacts_project_id}/${var.dataflow_repository_name}/${var.dataflow_template_jobs["bq_to_bq"]["image_name"]}"
  additional_parameters   = var.dataflow_template_jobs["bq_to_bq"]["additional_parameters"]

  parameters = {
    input_table                    = "${local.data_domain_non_confidential_project}:${var.business_code}_${var.bigquery_non_confidential_dataset_id_prefix}_${each.value.dataset_name}_${var.env}.${each.value.table_name}"
    output_table                   = "${local.data_domain_confidential_project}:${var.business_code}_${var.bigquery_dataset_id_prefix}_${each.value.dataset_name}_${var.env}.${each.value.table_name}_confidential"
    bq_schema                      = each.value.schema
    bq_temp_loc                    = "gs://${module.dataflow_bucket.storage_bucket.name}/temp"
    dlp_project                    = local.data_governance_project_id
    dlp_location                   = var.region
    deidentification_template_name = local.dlp_deidentify_template_id
  }
}
