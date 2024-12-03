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

module "firestore_tag_engine" {
  source           = "../../modules/firestore"
  project_id       = local.data_governance_project_id
  location_id      = var.region
  database_id      = var.firestore_database_id
  firestore_type   = "FIRESTORE_NATIVE"
  deletion_policy  = "DELETE"
  concurrency_mode = "OPTIMISTIC"

  firestore_index_config_file = "${path.module}/../../static_data/firestore/firestore.yaml"
}
