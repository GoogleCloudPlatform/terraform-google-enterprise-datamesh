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

resource "google_bigquery_datapolicy_data_policy_iam_binding" "masked_reader" {
  provider = google-beta
  for_each = { for tag, value in var.sensitive_tags : tag => value }

  project        = google_bigquery_datapolicy_data_policy.masking_policy[each.key].project
  location       = google_bigquery_datapolicy_data_policy.masking_policy[each.key].location
  data_policy_id = google_bigquery_datapolicy_data_policy.masking_policy[each.key].id
  role           = "roles/bigquerydatapolicy.maskedReader"
  members        = var.masked_dataflow_controller_members
}

resource "google_data_catalog_taxonomy_iam_member" "data_bq_binding" {
  for_each = toset(var.fine_grained_access_control_members)
  provider = google-beta

  project  = google_data_catalog_taxonomy.secure_taxonomy.project
  taxonomy = google_data_catalog_taxonomy.secure_taxonomy.name
  role     = "roles/datacatalog.categoryFineGrainedReader"
  region   = var.location

  member = each.key
}

resource "google_data_catalog_taxonomy_iam_member" "data_viewer" {
  for_each = toset(var.datacatalog_viewer_members)
  provider = google-beta

  project  = google_data_catalog_taxonomy.secure_taxonomy.project
  taxonomy = google_data_catalog_taxonomy.secure_taxonomy.name
  role     = "roles/datacatalog.viewer"
  region   = var.location
  member   = each.key
}
