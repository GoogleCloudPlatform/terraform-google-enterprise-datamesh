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



##########################################
# Data Catalog
##########################################

module "data_catalog_development" {
  for_each = toset(distinct([for domain in var.dlp_job_inspect_datasets : domain.domain_name]))
  source   = "../../modules/data_catalog"

  project_id       = local.data_governance_project_id
  location         = var.region
  data_domain_name = each.key
  environment      = "development"

  taxonomy_display_name = "secured_taxonomy_${replace(each.key, "-", "_")}_dev"
  sensitive_tags        = var.data_catalog_sensitive_tags

  fine_grained_access_control_members = [
    "serviceAccount:${local.bigquery_default_service_accounts_confidential_dev[each.key]}",
    "serviceAccount:${local.dataflow_controller_service_accounts_dev[each.key]}",
    "serviceAccount:${local.data_governance_sa_tag_creator}",
    "serviceAccount:${local.cloud_run_sa}",
    "serviceAccount:${local.record_manager_sa}",
    "group:${local.consumer_groups_email.fine_grained_data_viewer}"
  ]

  masked_dataflow_controller_members = [
    "serviceAccount:${local.dataflow_controller_service_accounts_dev[each.key]}",
    "serviceAccount:${local.cloud_run_sa}",
    "serviceAccount:${local.record_manager_sa}",
    "group:${local.consumer_groups_email.masked_data_viewer}"
  ]

  datacatalog_viewer_members = [
    "serviceAccount:${local.terraform_service_accounts["${each.key}-non-conf"]}",
    "serviceAccount:${local.terraform_service_accounts["${each.key}-conf"]}"
  ]

}

module "data_catalog_nonproduction" {
  for_each = toset(distinct([for domain in var.dlp_job_inspect_datasets : domain.domain_name]))
  source   = "../../modules/data_catalog"

  project_id       = local.data_governance_project_id
  location         = var.region
  data_domain_name = each.key
  environment      = "nonproduction"

  taxonomy_display_name = "secured_taxonomy_${replace(each.key, "-", "_")}_nonp"
  sensitive_tags        = var.data_catalog_sensitive_tags

  fine_grained_access_control_members = [
    "serviceAccount:${local.bigquery_default_service_accounts_confidential_nonp[each.key]}",
    "serviceAccount:${local.dataflow_controller_service_accounts_nonp[each.key]}",
    "serviceAccount:${local.data_governance_sa_tag_creator}",
    "serviceAccount:${local.cloud_run_sa}",
    "group:${local.consumer_groups_email.fine_grained_data_viewer}"
  ]

  masked_dataflow_controller_members = [
    "serviceAccount:${local.dataflow_controller_service_accounts_nonp[each.key]}",
    "serviceAccount:${local.cloud_run_sa}",
    "group:${local.consumer_groups_email.masked_data_viewer}"
  ]

  datacatalog_viewer_members = [
    "serviceAccount:${local.terraform_service_accounts["${each.key}-non-conf"]}",
    "serviceAccount:${local.terraform_service_accounts["${each.key}-conf"]}"
  ]

}

module "data_catalog_production" {
  for_each = toset(distinct([for domain in var.dlp_job_inspect_datasets : domain.domain_name]))
  source   = "../../modules/data_catalog"

  project_id       = local.data_governance_project_id
  location         = var.region
  data_domain_name = each.key
  environment      = "production"

  taxonomy_display_name = "secured_taxonomy_${replace(each.key, "-", "_")}_prod"
  sensitive_tags        = var.data_catalog_sensitive_tags

  fine_grained_access_control_members = [
    "serviceAccount:${local.bigquery_default_service_accounts_confidential_prod[each.key]}",
    "serviceAccount:${local.dataflow_controller_service_accounts_prod[each.key]}",
    "serviceAccount:${local.data_governance_sa_tag_creator}",
    "serviceAccount:${local.cloud_run_sa}",
    "group:${local.consumer_groups_email.fine_grained_data_viewer}"
  ]

  masked_dataflow_controller_members = [
    "serviceAccount:${local.dataflow_controller_service_accounts_prod[each.key]}",
    "serviceAccount:${local.cloud_run_sa}",
    "group:${local.consumer_groups_email.masked_data_viewer}"
  ]

  datacatalog_viewer_members = [
    "serviceAccount:${local.terraform_service_accounts["${each.key}-non-conf"]}",
    "serviceAccount:${local.terraform_service_accounts["${each.key}-conf"]}"
  ]


  datacatalog_templates = [
    "${path.module}/../../templates/tag_templates/cdmc_controls.yaml",
    "${path.module}/../../templates/tag_templates/completeness_template.yaml",
    "${path.module}/../../templates/tag_templates/correctness_template.yaml",
    "${path.module}/../../templates/tag_templates/cost_metrics.yaml",
    "${path.module}/../../templates/tag_templates/data_sensitivity.yaml",
    "${path.module}/../../templates/tag_templates/impact_assessment.yaml",
    "${path.module}/../../templates/tag_templates/security_policy.yaml",
    "${path.module}/../../templates/tag_templates/uniqueness_template.yaml"
  ]

}
