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
  env_short_form = {
    development   = "dev"
    nonproduction = "nonp"
    production    = "prod"
  }

  config_to_endpoint_mapping = {
    cdmc_controls     = "create_dynamic_table_config"
    completeness      = "create_dynamic_column_config"
    correctness       = "create_dynamic_column_config"
    cost_metrics      = "create_dynamic_table_config"
    data_sensitivity  = "create_sensitive_column_config"
    export_all_tags   = "create_export_config"
    impact_assessment = "create_dynamic_table_config"
    security_policy   = "create_dynamic_column_config"
  }

  orchestration_to_uuid_mapping = {
    caller-workflow       = null
    tag-exp-all-templates = "export_all_tags"
    tag-cdmc-controls     = "cdmc_controls"
    tag-completeness      = "completeness"
    tag-correctness       = "correctness"
    tag-cost-metrics      = "cost_metrics"
    tag-data-sensitivity  = "data_sensitivity"
    tag-impact-assessment = "impact_assessment"
    tag-security-policy   = "security_policy"
  }
}

resource "terracurl_request" "tag_engine_configs" {
  for_each = { for output in setproduct(
    var.dlp_job_inspect_datasets,
    keys(local.config_to_endpoint_mapping)
    ) : "${output[0].domain_name}-${output[0].inspection_dataset}-${output[1]}" => {
    domain   = output[0]
    config   = output[1]
    endpoint = local.config_to_endpoint_mapping[output[1]]
  } if output[0].environment == var.environment }

  headers = {
    Authorization = "Bearer ${data.google_service_account_id_token.default.id_token}"
    oauth_token   = data.google_client_config.account.access_token
  }

  method  = "POST"
  name    = "${each.value.config}-${var.environment}"
  timeout = var.curl_timeout

  request_body = templatefile("${var.tag_engine_config_path}/${each.value.config}.json", {
    environment            = var.environment
    domain_name            = replace(each.value.domain.domain_name, "-", "_")
    env_short_form         = local.env_short_form[var.environment]
    region                 = var.region
    inspection_dataset_id  = each.value.domain.inspection_dataset
    project_id_data        = var.data_domain_projects[each.value.domain.domain_name].project_id
    project_number_data    = var.data_domain_projects[each.value.domain.domain_name].project_number
    project_id_gov         = var.project_id
    resulting_dataset_id   = each.value.domain.resulting_dataset
    taxonomy_id            = var.data_catalog_environment[each.value.domain.domain_name].secure_taxonomy.id
    pricing_export_dataset = var.pricing_export_dataset_name
  })

  response_codes = [
    200,
    400
  ]

  lifecycle {
    ignore_changes = [headers]
  }

  url = "${var.tag_engine_service_uri}/${each.value.endpoint}"
}

resource "google_workflows_workflow" "orchestration" {
  for_each = { for output in setproduct(
    var.dlp_job_inspect_datasets,
    keys(local.orchestration_to_uuid_mapping)
    ) : "${output[0].domain_name}-${output[0].inspection_dataset}-${output[1]}" => {
    domain        = output[0]
    orchestration = output[1]
    uuid          = local.orchestration_to_uuid_mapping[output[1]]
  } if output[0].environment == var.environment }

  project = var.project_id

  name            = "${each.value.orchestration}-${each.value.domain.inspection_dataset}"
  region          = var.region
  service_account = var.cloud_run_sa
  source_contents = templatefile("${var.tag_engine_orchistration_path}/${replace(each.value.orchestration, "-", "_")}.yaml", {
    config_uuid           = each.value.uuid == null ? "" : jsondecode(terracurl_request.tag_engine_configs["${each.value.domain.domain_name}-${each.value.domain.inspection_dataset}-${each.value.uuid}"].response).config_uuid
    inspection_dataset_id = each.value.domain.inspection_dataset
    project_id_gov        = var.project_id
    tag_engine_url        = var.tag_engine_service_uri
    cloud_run_sa          = var.cloud_run_sa
    domain_name           = each.value.domain.domain_name
    environment           = var.environment
  })

  depends_on = [terracurl_request.tag_engine_configs]
}
