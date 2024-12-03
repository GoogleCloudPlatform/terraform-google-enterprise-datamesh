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

variable "remote_state_bucket" {
  description = "Backend bucket to load Terraform Remote State Data from previous steps."
  type        = string
}

variable "consumer_groups" {
  type = object({
    confidential_data_viewer                  = string
    non_confidential_data_viewer              = string
    non_confidential_encrypted_data_viewer    = string
    non_confidential_fine_grained_data_viewer = string
    non_confidential_masked_data_viewer       = string
  })
}

variable "create_resource_locations_policy" {
  description = <<EOT
    Whether to create the Organization policy to limit resource location for confidential and non-confidential projects
    Required for the Tag engine. However, if the policy is created on the initial Terraform apply, the validation (gcloud terraform vet)
    fails with error: Error converting TF resource to CAI: Invalid parent address() for an asset.
    So the idea is to skip the policy creation on the initial Terraform apply, then enable it once the projects are created.
    EOT
  type        = bool
  default     = true
}
