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

# locals {
#   sensitive_tags = data.terraform_remote_state.data_governance.outputs.sensitive_tag_ids_production[var.domain_name]
# }

# data "terraform_remote_state" "data_governance" {
#   backend = "gcs"

#   config = {
#     bucket = var.data_governance_state_bucket
#     prefix = "terraform/development"
#   }
# }
