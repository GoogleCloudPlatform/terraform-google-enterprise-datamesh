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

  project_id       = local.injestion_project_id
  name             = "dataflow"
  domain_name      = var.domain_name
  business_code    = var.business_code
  environment      = var.env
  kms_project_id   = local.shared_kms_project_id
  environment_code = var.env_code
  log_bucket_name  = local.logging_bucket_name
}

module "cloudfunction_bucket" {
  source = "../bucket"

  project_id       = local.injestion_project_id
  name             = "cloudfunction"
  domain_name      = var.domain_name
  business_code    = var.business_code
  environment      = var.env
  kms_project_id   = local.shared_kms_project_id
  environment_code = var.env_code
  log_bucket_name  = local.logging_bucket_name
}

module "pub_sub_topic" {
  source = "../pubsub"

  project_id     = local.injestion_project_id
  topic          = "data_ingestion"
  kms_project_id = local.env_kms_project_id
  topic_labels = merge({
    env = var.env
    app = "data_ingestion"
  }, var.pubsub_topic_labels_additional)
  message_storage_policy = {
    allowed_persistence_regions = concat([var.region], var.pubsub_message_storage_policy_regions_additional)
  }

  pull_subscriptions = [
    {
      name = "ingestion-pull-sub-${var.env}"
    }
  ]
}

module "dataflow_flex_job_pubsub_to_bq" {
  source = "../dataflow_flex_job"
  for_each = { for item in flatten([
    for dataset in var.non_confidential_datasets : [
      for table_name, schema in dataset.tables_schema : {
        dataset_name = dataset.name
        table_name   = table_name
        schema       = schema
        pubsub_off   = dataset.pubsub_off
      }
    ]
    ]) : "${item.dataset_name}_${item.table_name}" => item
    if item.pubsub_off == false
  }

  project_id              = local.injestion_project_id
  kms_project_id          = local.shared_kms_project_id
  name                    = "dataflow-pubsub-to-bq-${replace(each.value.table_name, "_", "-")}-${var.env}"
  region                  = var.region
  network                 = local.restricted_network_name
  dataflow_gcs_bucket_url = var.dataflow_gcs_bucket_url
  subnetworks             = local.restricted_subnets_names
  network_project_id      = local.restricted_host_project_id
  service_account_email   = local.dataflow_controller_service_account
  business_code           = var.business_code
  environment             = var.env
  domain_name             = var.domain_name
  max_workers             = 10
  ip_configuration        = "WORKER_IP_PRIVATE"
  template_filename       = var.dataflow_template_jobs["pubsub_to_bq"]["template_filename"]
  temp_location           = "gs://${module.dataflow_bucket.storage_bucket.name}/temp/"
  staging_location        = "gs://${module.dataflow_bucket.storage_bucket.name}/staging/"
  sdk_container_image     = "${var.region}-docker.pkg.dev/${local.app_infra_artifacts_project_id}/${var.dataflow_repository_name}/${var.dataflow_template_jobs["pubsub_to_bq"]["image_name"]}"
  additional_parameters   = var.dataflow_template_jobs["pubsub_to_bq"]["additional_parameters"]

  parameters = {
    input_subscription             = module.pub_sub_topic.subscription_paths[0]
    deidentification_template_name = local.dlp_deidentify_template_id,
    dlp_location                   = var.region,
    dlp_project                    = local.data_governance_project_id,
    output_table                   = "${local.non_confidential_data_project_id}.${each.value.dataset_name}_${var.env}.${each.value.table_name}",
    bq_schema                      = each.value.schema,
    window_interval_sec            = 30
    cryptoKeyName                  = local.deidentify_kms_key
    wrappedKey                     = data.google_secret_manager_secret_version.wrapped_key.name
  }
}

module "dataflow_flex_job_gcs_to_bq" {
  for_each = { for item in flatten([
    for dataset in var.non_confidential_datasets : [
      for table_name, filename in dataset.tables_file_names : {
        dataset_name  = dataset.name
        table_name    = table_name
        schema        = dataset.tables_schema[table_name]
        csv_file_name = filename
        gcs_input_off = dataset.gcs_input_off
      }
    ]
    ]) : "${item.dataset_name}_${item.table_name}" => item
    if item.gcs_input_off == false
  }
  source = "../dataflow_flex_job"

  project_id              = local.injestion_project_id
  kms_project_id          = local.shared_kms_project_id
  name                    = "dataflow-${lower(replace(replace(each.value.csv_file_name, "_", "-"), ".", "-"))}-${var.env}"
  region                  = var.region
  network                 = local.restricted_network_name
  dataflow_gcs_bucket_url = var.dataflow_gcs_bucket_url
  subnetworks             = local.restricted_subnets_names
  network_project_id      = local.restricted_host_project_id
  service_account_email   = local.dataflow_controller_service_account
  business_code           = var.business_code
  environment             = var.env
  domain_name             = var.domain_name
  max_workers             = 10
  ip_configuration        = "WORKER_IP_PRIVATE"
  template_filename       = var.dataflow_template_jobs["gcs_to_bq"]["template_filename"]
  temp_location           = "gs://${module.dataflow_bucket.storage_bucket.name}/temp/"
  staging_location        = "gs://${module.dataflow_bucket.storage_bucket.name}/staging/"
  sdk_container_image     = "${var.region}-docker.pkg.dev/${local.app_infra_artifacts_project_id}/${var.dataflow_repository_name}/${var.dataflow_template_jobs["gcs_to_bq"]["image_name"]}"
  additional_parameters   = var.dataflow_template_jobs["gcs_to_bq"]["additional_parameters"]

  parameters = {
    gcs_input_file                 = "${local.data_ingestion_bucket}/${each.value.csv_file_name}",
    deidentification_template_name = local.dlp_deidentify_template_id,
    dlp_location                   = var.region,
    dlp_project                    = local.data_governance_project_id,
    output_table                   = "${local.non_confidential_data_project_id}.${each.value.dataset_name}_${var.env}.${each.value.table_name}",
    bq_schema                      = each.value.schema,
    cryptoKeyName                  = local.deidentify_kms_key
    wrappedKey                     = data.google_secret_manager_secret_version.wrapped_key.name
  }
}
