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
  data_labels = {
    cdmc            = "data_quality"
    data_governance = true
    environment     = var.environment
  }

  ddl_data_access = [
    "serviceAccount:${local.data_governance_sa_tag_creator}",
    "serviceAccount:${local.report_engine_sa}",
  ]
}

##########################################
# BigQuery Data Loss Prevention Datasets
##########################################

module "bigquery_dlp_development" {
  for_each = toset([for domain in var.dlp_job_inspect_datasets : domain.resulting_dataset if domain.environment == "development"])
  source   = "../../modules/bigquery"

  project_id   = local.data_governance_project_id
  dataset_id   = each.key
  dataset_name = "Data Loss Prevention ${each.key} Dev"
  location     = var.region

  encryption_key             = local.bq_data_quality_kms_key
  delete_contents_on_destroy = true
}

module "bigquery_dlp_nonproduction" {
  for_each = toset([for domain in var.dlp_job_inspect_datasets : domain.resulting_dataset if domain.environment == "nonproduction"])
  source   = "../../modules/bigquery"

  project_id   = local.data_governance_project_id
  dataset_id   = each.key
  dataset_name = "Data Loss Prevention ${each.key} Non Production"
  location     = var.region

  encryption_key             = local.bq_data_quality_kms_key
  delete_contents_on_destroy = true
}

module "bigquery_dlp_production" {
  for_each = toset([for domain in var.dlp_job_inspect_datasets : domain.resulting_dataset if domain.environment == "production"])
  source   = "../../modules/bigquery"

  project_id   = local.data_governance_project_id
  dataset_id   = each.key
  dataset_name = "Data Loss Prevention ${each.key} Production"
  location     = var.region

  encryption_key             = local.bq_data_quality_kms_key
  delete_contents_on_destroy = true
}

##########################################
# BigQuery Data Quality Datasets
##########################################

module "bigquery_dataquality_development" {
  for_each = toset([for domain in var.dlp_job_inspect_datasets : domain.domain_name])
  source   = "../../modules/bigquery"

  project_id   = local.data_governance_project_id
  dataset_id   = "cloud_dq_${replace(each.key, "-", "_")}_dev"
  dataset_name = "Data Quality ${each.key} Dev"
  location     = var.region

  delete_contents_on_destroy = true

  encryption_key = local.bq_data_quality_kms_key

  dataset_labels = local.data_labels
}

module "bigquery_dataquality_nonproduction" {
  for_each = toset([for domain in var.dlp_job_inspect_datasets : domain.domain_name])
  source   = "../../modules/bigquery"

  project_id   = local.data_governance_project_id
  dataset_id   = "cloud_dq_${replace(each.key, "-", "_")}_nonp"
  dataset_name = "Data Quality ${each.key} Non Production"
  location     = var.region

  delete_contents_on_destroy = true

  encryption_key = local.bq_data_quality_kms_key

  dataset_labels = local.data_labels
}

module "bigquery_dataquality_production" {
  for_each = toset([for domain in var.dlp_job_inspect_datasets : domain.domain_name])
  source   = "../../modules/bigquery"

  project_id   = local.data_governance_project_id
  dataset_id   = "cloud_dq_${replace(each.key, "-", "_")}_prod"
  dataset_name = "Data Quality ${each.key} Production"
  location     = var.region

  delete_contents_on_destroy = true

  encryption_key = local.bq_data_quality_kms_key

  dataset_labels = local.data_labels
}

##########################################
# BigQuery Tag History Datasets
##########################################
module "bigquery_tag_history_logs" {
  source = "../../modules/bigquery"

  project_id   = local.data_governance_project_id
  dataset_id   = var.tag_history_dataset_id
  dataset_name = "Tag History Logs"
  location     = var.region

  delete_contents_on_destroy = true

  encryption_key = local.bq_tag_history_kms_key

  dataset_labels = local.data_labels
}

##########################################
# BigQuery Pricing Export
##########################################

module "bigquery_pricing_export" {
  source = "../../modules/bigquery"

  project_id   = local.data_governance_project_id
  dataset_id   = var.pricing_export_dataset_name
  dataset_name = "Pricing Export"
  location     = "US"

  delete_contents_on_destroy = false
}

###########################################
# BigQuery Record Manager Datasets
###########################################

module "bigquery_record_manager_archives" {
  source   = "../../modules/bigquery"
  for_each = toset([var.record_manager_config["archives_dataset"], var.record_manager_config["snapshot_dataset"]])

  project_id   = local.data_governance_project_id
  dataset_id   = each.key
  dataset_name = "Record Manager ${each.key}"
  location     = var.region
}

###########################################
# BigQuery Dashboard Views
###########################################

module "bigquery_cdmc_report_tables" {
  source   = "../../modules/bigquery"
  for_each = toset(["dev", "nonp", "prod"])

  project_id   = local.data_governance_project_id
  dataset_id   = "cdmc_report_${each.key}"
  dataset_name = "cdmc_report_${each.key}"
  location     = var.region

  delete_contents_on_destroy = true
  tables = [for table in toset(fileset("${path.module}/../../static_data/reports", "*")) :
    {
      table_id   = table
      schema     = file("${path.module}/../../static_data/reports/${table}")
      clustering = []
      labels = {
        env = "cdmc"
      }
      time_partitioning = {
        expiration_ms = "2592000000"
        type          = "DAY"
        field         = table == "events" ? "ExecutionTimeStamp" : "event_timestamp"
      },
    }
  ]
}

module "bigquery_tag_export_tables" {
  source = "../../modules/bigquery"

  project_id   = local.data_governance_project_id
  dataset_id   = "tag_exports"
  dataset_name = "tag_exports"
  location     = var.region

  delete_contents_on_destroy = true
  tables = [for table in toset(fileset("${path.module}/../../static_data/tag_exports", "*")) :
    {
      table_id   = table
      schema     = file("${path.module}/../../static_data/tag_exports/${table}")
      clustering = []
      labels = {
        env = "cdmc"
      }
      time_partitioning = {
        expiration_ms = "2592000000"
        type          = "DAY"
        field         = "export_time"
      },
    }
  ]
}
