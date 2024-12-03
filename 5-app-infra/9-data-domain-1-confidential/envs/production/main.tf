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

module "confidential_project" {
  source = "../../modules/confidential_project"

  remote_state_bucket                         = var.remote_state_bucket
  data_governance_state_bucket                = var.data_governance_state_bucket
  business_unit                               = var.business_unit
  business_code                               = var.business_code
  domain_name                                 = var.domain_name
  env                                         = var.env
  env_code                                    = var.env_code
  region                                      = var.region
  bigquery_location                           = var.region
  bigquery_delete_contents_on_destroy         = true
  bigquery_dataset_id_prefix                  = var.bigquery_dataset_id_prefix
  bigquery_non_confidential_dataset_id_prefix = var.bigquery_non_confidential_dataset_id_prefix
  keyring_name                                = var.keyring_name

  additional_bigquery_dataset_labels = {
    dataset = "data-confidential"
  }
  dataflow_template_jobs   = var.dataflow_template_jobs
  dataflow_gcs_bucket_url  = var.dataflow_gcs_bucket_url
  dataflow_repository_name = var.dataflow_repository_name

  confidential_datasets = var.confidential_datasets
}
