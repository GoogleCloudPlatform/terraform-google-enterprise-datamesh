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
  project_location = var.create_resource_locations_policy ? {
    nonconfidential = {
      project_id = module.nonconfidential_project.project_id,
      regions    = keys(module.nonconfidential_project_keys)
    }
    confidential = {
      project_id = module.confidential_project.project_id,
      regions    = keys(module.nonconfidential_project_keys)
    }
  } : {}
}

resource "google_org_policy_policy" "resource_location_policy" {
  for_each = var.env != "development" ? local.project_location : {}

  name   = "projects/${each.value.project_id}/policies/gcp.resourceLocations"
  parent = "projects/${each.value.project_id}"

  spec {
    rules {
      values {
        allowed_values = [
          for region in each.value.regions : "in:${region}-locations"
        ]
      }
    }
  }
}
