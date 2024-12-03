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
  dataset_ids = [
    "dataset",
    "crm",
  ]
}

module "non_confidential_project" {
  source   = "../../modules/non-confidential-project"
  for_each = toset(local.dataset_ids)

  remote_state_bucket                 = var.remote_state_bucket
  business_unit                       = var.business_unit
  business_code                       = var.business_code
  domain_name                         = var.domain_name
  env                                 = var.env
  bigquery_dataset_id                 = "${var.business_code}_${var.dataset_id_prefix}_${each.key}_${var.env}"
  bigquery_description                = "Data Ingestion dataset"
  bigquery_dataset_name               = "Data Ingestion dataset"
  bigquery_location                   = var.region
  bigquery_delete_contents_on_destroy = true

  additional_bigquery_dataset_labels = {
    dataset = "data-ingestion"
  }
}
