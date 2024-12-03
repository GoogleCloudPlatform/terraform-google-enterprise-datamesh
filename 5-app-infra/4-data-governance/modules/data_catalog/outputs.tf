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

output "secure_taxonomy" {
  description = "Data Catalog Taxonomy"
  value       = google_data_catalog_taxonomy.secure_taxonomy
}

output "sensitive_tag_ids" {
  description = "Sensitive Tag IDs"
  value       = { for tag, values in var.sensitive_tags : tag => google_data_catalog_policy_tag.sensitive_tags[tag].id }
}
