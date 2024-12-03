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
  cdmc_controls_events_table_name = "events"
  cdmc_data_assets_table_name     = "data_assets"

  cdmc_controls_events_table_dev = module.bigquery_cdmc_report_tables["dev"].bigquery_tables[local.cdmc_controls_events_table_name]
  cdmc_data_assets_table_dev     = module.bigquery_cdmc_report_tables["dev"].bigquery_tables[local.cdmc_data_assets_table_name]

  cdmc_controls_events_table_nonp = module.bigquery_cdmc_report_tables["nonp"].bigquery_tables[local.cdmc_controls_events_table_name]
  cdmc_data_assets_table_nonp     = module.bigquery_cdmc_report_tables["nonp"].bigquery_tables[local.cdmc_data_assets_table_name]

  cdmc_controls_events_table_prod = module.bigquery_cdmc_report_tables["prod"].bigquery_tables[local.cdmc_controls_events_table_name]
  cdmc_data_assets_table_prod     = module.bigquery_cdmc_report_tables["prod"].bigquery_tables[local.cdmc_data_assets_table_name]
  cdmc_controls_topic             = "cdmc-controls-topic"
  cdmc_controls_subscription      = "cdmc-controls-topic-bq-sub"
  cdmc_data_assets_topic          = "cdmc-data-assets-topic"
  cdmc_data_assets_subscription   = "cdmc-data-assets-topic-bq-sub"
}

module "cdmc_report_views" {
  source   = "../../modules/report_engine_cdmc_report_views"
  for_each = toset(["dev", "nonp", "prod"])

  project_id  = local.data_governance_project_id
  environment = each.key
  region      = var.region
  dataset_id  = "cdmc_report_${each.key}"

  depends_on = [module.bigquery_cdmc_report_tables]
}

module "tag_export_views" {
  source = "../../modules/report_engine_tag_export_views"

  project_id = local.data_governance_project_id
  dataset_id = "tag_exports"

  depends_on = [module.bigquery_tag_export_tables]
}

module "cdmc_controls_topic" {
  source = "../../modules/pubsub"

  project_id = local.data_governance_project_id
  topic      = local.cdmc_controls_topic

  topic_labels = {
    env = "cdmc"
  }
  schema = {
    name       = "CDMC_Event"
    type       = "AVRO"
    definition = "{\"type\": \"record\",\"name\": \"CDMC_Event\",\"fields\": [{\"name\": \"reportMetadata\",\"type\": {\"type\": \"record\",\"name\": \"Identifier\",\"fields\": [{\"name\": \"uuid\",\"type\": \"string\"},{\"name\": \"Controls\",\"type\": \"string\"}]}},{\"name\": \"CdmcControlNumber\",\"type\": \"int\"},{\"name\": \"Findings\",\"type\": \"string\"},{\"name\": \"DataAsset\",\"type\": \"string\"},{\"name\": \"RecommendedAdjustment\",\"type\": \"string\"},{\"name\": \"ExecutionTimestamp\",\"type\": \"string\"}]}"
    encoding   = "JSON"
  }

  topic_kms_key_name = local.data_governance_kms_key

  bigquery_subscriptions = [
    {
      name             = "${local.cdmc_controls_subscription}_dev"
      table            = "${local.cdmc_controls_events_table_dev.project}.${local.cdmc_controls_events_table_dev.dataset_id}.${local.cdmc_controls_events_table_dev.table_id}"
      use_topic_schema = true
    },
    {
      name             = "${local.cdmc_controls_subscription}_nonp"
      table            = "${local.cdmc_controls_events_table_nonp.project}.${local.cdmc_controls_events_table_nonp.dataset_id}.${local.cdmc_controls_events_table_nonp.table_id}"
      use_topic_schema = true
    },
    {
      name             = "${local.cdmc_controls_subscription}_prod"
      table            = "${local.cdmc_controls_events_table_prod.project}.${local.cdmc_controls_events_table_prod.dataset_id}.${local.cdmc_controls_events_table_prod.table_id}"
      use_topic_schema = true
    }
  ]
}

module "cdmc_data_assets_topic" {
  source = "../../modules/pubsub"

  project_id = local.data_governance_project_id
  topic      = local.cdmc_data_assets_topic

  topic_labels = {
    env = "cdmc"
  }
  schema = {
    name       = "CDMC_Data_Assets"
    type       = "AVRO"
    definition = "{\"type\": \"record\",\"name\": \"CDMC_Data_Assets\",\"fields\": [{\"name\": \"event_uuid\",\"type\": \"string\"},{\"name\": \"asset_name\",\"type\": \"string\"},{\"name\": \"sensitive\",\"type\": \"boolean\"},{\"name\": \"event_timestamp\",\"type\": \"string\"}]}"
    encoding   = "JSON"
  }
  topic_kms_key_name = local.data_governance_kms_key

  bigquery_subscriptions = [
    {
      name             = "${local.cdmc_data_assets_subscription}_dev"
      table            = "${local.cdmc_data_assets_table_dev.project}.${local.cdmc_data_assets_table_dev.dataset_id}.${local.cdmc_data_assets_table_dev.table_id}"
      use_topic_schema = true
    },
    {
      name             = "${local.cdmc_data_assets_subscription}_nonp"
      table            = "${local.cdmc_data_assets_table_nonp.project}.${local.cdmc_data_assets_table_nonp.dataset_id}.${local.cdmc_data_assets_table_nonp.table_id}"
      use_topic_schema = true
    },
    {
      name             = "${local.cdmc_data_assets_subscription}_prod"
      table            = "${local.cdmc_data_assets_table_prod.project}.${local.cdmc_data_assets_table_prod.dataset_id}.${local.cdmc_data_assets_table_prod.table_id}"
      use_topic_schema = true
    }
  ]
}


module "report_engine_development" {
  source   = "../../modules/report_engine"
  for_each = toset([for domain in var.dlp_job_inspect_datasets : domain.domain_name])

  project_id      = local.data_governance_project_id
  organization_id = local.organization_id
  region          = var.region
  environment     = "dev"
  domain_name     = each.key

  data_domain_project_id     = local.data_domain_non_conf_projects_dev[each.key].project_id
  data_domain_project_number = local.data_domain_non_conf_projects_dev[each.key].project_number

  cdmc_data_assets_topic = local.cdmc_data_assets_topic
  cdmc_controls_topic    = local.cdmc_controls_topic

  cloud_run_service = {
    image_name                 = var.report_engine_image_name
    image_tag                  = var.report_engine_image_tag
    service_account            = local.report_engine_sa
    artifact_project_id        = local.artifact_project_id
    artifact_repository_name   = var.artifact_repository_name
    artifact_repository_folder = var.artifact_repository_folder
    environment_variables = {
      "PROJECT_ID_DATA" = local.data_governance_project_id
      "PROJECT_ID_GOV"  = local.data_governance_project_id
      "DATASET_SUFFIX"  = "_${replace(each.key, "-", "_")}_dev"
    }
  }

  controls                         = "all"
  worklow_run_sa                   = local.cloud_run_sa
  report_engine_orchestration_path = "${path.module}/../../static_data/report_engine_orchestration/generate_report.yaml"

  depends_on = [
    module.bigquery_cdmc_report_tables,
  ]
}

module "report_engine_nonproduction" {
  source   = "../../modules/report_engine"
  for_each = toset([for domain in var.dlp_job_inspect_datasets : domain.domain_name])

  project_id      = local.data_governance_project_id
  organization_id = local.organization_id
  region          = var.region
  environment     = "nonp"
  domain_name     = each.key

  data_domain_project_id     = local.data_domain_non_conf_projects_nonp[each.key].project_id
  data_domain_project_number = local.data_domain_non_conf_projects_nonp[each.key].project_number

  cdmc_data_assets_topic = local.cdmc_data_assets_topic
  cdmc_controls_topic    = local.cdmc_controls_topic

  cloud_run_service = {
    image_name                 = var.report_engine_image_name
    image_tag                  = var.report_engine_image_tag
    service_account            = local.report_engine_sa
    artifact_project_id        = local.artifact_project_id
    artifact_repository_name   = var.artifact_repository_name
    artifact_repository_folder = var.artifact_repository_folder
    environment_variables = {
      "PROJECT_ID_DATA" = local.data_governance_project_id
      "PROJECT_ID_GOV"  = local.data_governance_project_id
      "DATASET_SUFFIX"  = "_${replace(each.key, "-", "_")}_nonp"
    }
  }

  controls                         = "all"
  worklow_run_sa                   = local.cloud_run_sa
  report_engine_orchestration_path = "${path.module}/../../static_data/report_engine_orchestration/generate_report.yaml"

  depends_on = [
    module.bigquery_cdmc_report_tables,
  ]
}

module "report_engine_production" {
  source   = "../../modules/report_engine"
  for_each = toset([for domain in var.dlp_job_inspect_datasets : domain.domain_name])

  project_id      = local.data_governance_project_id
  organization_id = local.organization_id
  region          = var.region
  environment     = "prod"
  domain_name     = each.key

  data_domain_project_id     = local.data_domain_non_conf_projects_prod[each.key].project_id
  data_domain_project_number = local.data_domain_non_conf_projects_prod[each.key].project_number

  cdmc_data_assets_topic = local.cdmc_data_assets_topic
  cdmc_controls_topic    = local.cdmc_controls_topic

  cloud_run_service = {
    image_name                 = var.report_engine_image_name
    image_tag                  = var.report_engine_image_tag
    service_account            = local.report_engine_sa
    artifact_project_id        = local.artifact_project_id
    artifact_repository_name   = var.artifact_repository_name
    artifact_repository_folder = var.artifact_repository_folder
    environment_variables = {
      "PROJECT_ID_DATA" = local.data_governance_project_id
      "PROJECT_ID_GOV"  = local.data_governance_project_id
      "DATASET_SUFFIX"  = "_${replace(each.key, "-", "_")}_prod"
    }
  }

  controls                         = "all"
  worklow_run_sa                   = local.cloud_run_sa
  report_engine_orchestration_path = "${path.module}/../../static_data/report_engine_orchestration/generate_report.yaml"

  depends_on = [
    module.bigquery_cdmc_report_tables,
  ]
}
