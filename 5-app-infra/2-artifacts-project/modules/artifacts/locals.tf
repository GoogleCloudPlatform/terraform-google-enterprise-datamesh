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
  registry_repository_types = [
    {
      format      = "PYTHON"
      description = "Repository for Python modules for Dataflow flex templates"
      id          = "python-modules"
    },
    {
      format      = "DOCKER"
      description = "DataFlow Flex Templates"
      id          = "flex-templates"
    },
    {
      format      = "DOCKER"
      description = "CDMC Images"
      id          = "cdmc"
    }
  ]

  kms_key_encrypter_decrypter_service_accounts = [
    "service-${data.google_project.project.number}@gcp-sa-artifactregistry.iam.gserviceaccount.com",
    "service-${data.google_project.project.number}@gs-project-accounts.iam.gserviceaccount.com",
  ]

  kms_keys = flatten([
    for region, key_region in local.app_infra_artifacts_kms_keys : [
      for sa in local.kms_key_encrypter_decrypter_service_accounts : {
        key_id   = key_region.id
        key_name = key_region.name
        region   = region
        sa       = sa
      }
    ]
  ])
}
