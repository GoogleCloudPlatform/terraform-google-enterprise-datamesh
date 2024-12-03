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

module "data_ingestion" {
  source = "../../modules/data_ingestion_project"

  remote_state_bucket          = var.remote_state_bucket
  business_unit                = var.business_unit
  business_code                = var.business_code
  domain_name                  = var.domain_name
  env                          = var.env
  region                       = var.region
  dataflow_gcs_bucket_url      = var.dataflow_gcs_bucket_url
  data_governance_state_bucket = var.data_governance_state_bucket
  dataflow_repository_name     = var.dataflow_repository_name
  dataflow_template_jobs       = var.dataflow_template_jobs
  env_code                     = var.env_code
  non_confidential_datasets    = var.non_confidential_datasets
}

