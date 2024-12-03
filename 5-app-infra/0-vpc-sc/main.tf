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

terraform {
  required_version = ">= 1.5.7"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.43, < 6"
    }
  }
}

variable "remote_state_bucket" {
  description = "Backend bucket to load Terraform Remote State Data from previous steps."
  type        = string
}

data "terraform_remote_state" "org" {
  backend = "gcs"

  config = {
    bucket = var.remote_state_bucket
    prefix = "terraform/org/state"
  }
}

data "terraform_remote_state" "environments_env_dev" {
  backend = "gcs"

  config = {
    bucket = var.remote_state_bucket
    prefix = "terraform/environments/development"
  }
}

data "terraform_remote_state" "environments_env_nonprod" {
  backend = "gcs"

  config = {
    bucket = var.remote_state_bucket
    prefix = "terraform/environments/nonproduction"
  }
}

data "terraform_remote_state" "environments_env_production" {
  backend = "gcs"

  config = {
    bucket = var.remote_state_bucket
    prefix = "terraform/environments/production"
  }
}

data "terraform_remote_state" "network_env_shared" {
  backend = "gcs"

  config = {
    bucket = var.remote_state_bucket
    prefix = "terraform/networks/envs/shared"
  }
}

data "terraform_remote_state" "network_env_dev" {
  backend = "gcs"

  config = {
    bucket = var.remote_state_bucket
    prefix = "terraform/networks/development"
  }
}

data "terraform_remote_state" "network_env_nonprod" {
  backend = "gcs"

  config = {
    bucket = var.remote_state_bucket
    prefix = "terraform/networks/nonproduction"
  }
}

data "terraform_remote_state" "network_env_production" {
  backend = "gcs"

  config = {
    bucket = var.remote_state_bucket
    prefix = "terraform/networks/production"
  }
}

data "terraform_remote_state" "business_unit_env_shared" {
  backend = "gcs"

  config = {
    bucket = var.remote_state_bucket
    prefix = "terraform/projects/business_unit_4/shared"
  }
}

data "terraform_remote_state" "business_unit_env_dev" {
  backend = "gcs"

  config = {
    bucket = var.remote_state_bucket
    prefix = "terraform/projects/business_unit_4/development"
  }
}

data "terraform_remote_state" "business_unit_env_nonprod" {
  backend = "gcs"

  config = {
    bucket = var.remote_state_bucket
    prefix = "terraform/projects/business_unit_4/nonproduction"
  }
}

data "terraform_remote_state" "business_unit_env_production" {
  backend = "gcs"

  config = {
    bucket = var.remote_state_bucket
    prefix = "terraform/projects/business_unit_4/production"
  }
}


locals {
  common_service_perimeter                     = data.terraform_remote_state.network_env_shared.outputs.restricted_service_perimeter_name
  access_context_manager_policy_id             = data.terraform_remote_state.network_env_shared.outputs.access_context_manager_policy_id
  development_service_perimeter                = data.terraform_remote_state.network_env_dev.outputs.restricted_service_perimeter_name
  nonprod_service_perimeter                    = data.terraform_remote_state.network_env_nonprod.outputs.restricted_service_perimeter_name
  production_service_perimeter                 = data.terraform_remote_state.network_env_production.outputs.restricted_service_perimeter_name
  common_shared_restricted_project_number      = data.terraform_remote_state.org.outputs.shared_vpc_projects["common"]["restricted_shared_vpc_project_number"]
  development_shared_restricted_project_number = data.terraform_remote_state.org.outputs.shared_vpc_projects["development"]["restricted_shared_vpc_project_number"]
  nonprod_shared_restricted_project_number     = data.terraform_remote_state.org.outputs.shared_vpc_projects["nonproduction"]["restricted_shared_vpc_project_number"]
  production_shared_restricted_project_number  = data.terraform_remote_state.org.outputs.shared_vpc_projects["production"]["restricted_shared_vpc_project_number"]
  common_kms_project_number                    = data.terraform_remote_state.org.outputs.common_kms_project_number
  development_kms_project_number               = data.terraform_remote_state.environments_env_dev.outputs.env_kms_project_number
  nonprod_kms_project_number                   = data.terraform_remote_state.environments_env_nonprod.outputs.env_kms_project_number
  production_kms_project_number                = data.terraform_remote_state.environments_env_production.outputs.env_kms_project_number
  common_secrets_project_number                = data.terraform_remote_state.org.outputs.org_secrets_project_number
  org_audit_logs_project_id                    = data.terraform_remote_state.org.outputs.org_audit_logs_project_id
  data_governance_project_number               = data.terraform_remote_state.business_unit_env_shared.outputs.data_governance_project_number
  data_governance_project_id                   = data.terraform_remote_state.business_unit_env_shared.outputs.data_governance_project_id
  artifacts_project_number                     = data.terraform_remote_state.business_unit_env_shared.outputs.app_infra_artifacts_project_number
  tf_sa_data_domain_1_non_conf_sa              = data.terraform_remote_state.business_unit_env_shared.outputs.terraform_service_accounts["domain-1-non-conf"]
  tf_sa_data_domain_1_conf_sa                  = data.terraform_remote_state.business_unit_env_shared.outputs.terraform_service_accounts["domain-1-conf"]
  tf_sa_data_domain_1_ingest_sa                = data.terraform_remote_state.business_unit_env_shared.outputs.terraform_service_accounts["domain-1-ingest"]
  tf_sa_data_governance_sa                     = data.terraform_remote_state.business_unit_env_shared.outputs.terraform_service_accounts["data-governance"]
  tf_sa_service_catalog                        = data.terraform_remote_state.business_unit_env_shared.outputs.terraform_service_accounts["service-catalog"]
  dev_data_domain_1_non_conf                   = data.terraform_remote_state.business_unit_env_dev.outputs.data_domain_non_confidential_projects["domain-1"]["project_number"]
  dev_data_domain_1_non_conf_id                = data.terraform_remote_state.business_unit_env_dev.outputs.data_domain_non_confidential_projects["domain-1"]["project_id"]
  dev_data_domain_1_conf                       = data.terraform_remote_state.business_unit_env_dev.outputs.data_domain_confidential_projects["domain-1"]["project_number"]
  dev_data_domain_1_conf_id                    = data.terraform_remote_state.business_unit_env_dev.outputs.data_domain_confidential_projects["domain-1"]["project_id"]
  dev_consumer_1                               = data.terraform_remote_state.business_unit_env_dev.outputs.consumer_projects["consumer-1"]["project_number"]
  nonprod_data_domain_1_non_conf               = data.terraform_remote_state.business_unit_env_nonprod.outputs.data_domain_non_confidential_projects["domain-1"]["project_number"]
  nonprod_data_domain_1_conf                   = data.terraform_remote_state.business_unit_env_nonprod.outputs.data_domain_confidential_projects["domain-1"]["project_number"]
  nonprod_data_domain_1_conf_id                = data.terraform_remote_state.business_unit_env_nonprod.outputs.data_domain_confidential_projects["domain-1"]["project_id"]
  nonprod_consumer_1                           = data.terraform_remote_state.business_unit_env_nonprod.outputs.consumer_projects["consumer-1"]["project_number"]
  prod_data_domain_1_non_conf                  = data.terraform_remote_state.business_unit_env_production.outputs.data_domain_non_confidential_projects["domain-1"]["project_number"]
  prod_data_domain_1_conf                      = data.terraform_remote_state.business_unit_env_production.outputs.data_domain_confidential_projects["domain-1"]["project_number"]
  prod_data_domain_1_conf_id                   = data.terraform_remote_state.business_unit_env_production.outputs.data_domain_confidential_projects["domain-1"]["project_id"]
  prod_consumer_1                              = data.terraform_remote_state.business_unit_env_production.outputs.consumer_projects["consumer-1"]["project_number"]
  dev_data_domain_ingest                       = data.terraform_remote_state.business_unit_env_dev.outputs.data_domain_ingestion_projects["domain-1"]["project_number"]
  dev_data_domain_ingest_id                    = data.terraform_remote_state.business_unit_env_dev.outputs.data_domain_ingestion_projects["domain-1"]["project_id"]
  nonprod_data_domain_ingest                   = data.terraform_remote_state.business_unit_env_nonprod.outputs.data_domain_ingestion_projects["domain-1"]["project_number"]
  nonprod_data_domain_ingest_id                = data.terraform_remote_state.business_unit_env_nonprod.outputs.data_domain_ingestion_projects["domain-1"]["project_id"]
  prod_data_domain_ingest                      = data.terraform_remote_state.business_unit_env_production.outputs.data_domain_ingestion_projects["domain-1"]["project_number"]
  prod_data_domain_ingest_id                   = data.terraform_remote_state.business_unit_env_production.outputs.data_domain_ingestion_projects["domain-1"]["project_id"]
  service_catalog_project_number               = data.terraform_remote_state.business_unit_env_shared.outputs.service_catalog["project_number"]
  data_viewer_groups                           = data.terraform_remote_state.business_unit_env_shared.outputs.data_viewer_groups_email
}


data "google_project" "audit_logs_project" {
  project_id = local.org_audit_logs_project_id
}
