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

output "tag_engine_config_response" {
  description = "values of tag engine config responses"
  value = {
    for domain in var.dlp_job_inspect_datasets :
    "${domain.domain_name}-${domain.inspection_dataset}" => merge(
      {
        for config in keys(local.config_to_endpoint_mapping) :
        config => try(jsondecode(terracurl_request.tag_engine_configs["${domain.domain_name}-${domain.inspection_dataset}-${config}"].response), "")
      }
    )
  }
}
