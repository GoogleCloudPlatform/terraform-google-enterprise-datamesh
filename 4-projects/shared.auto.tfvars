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

# We suggest you to use the same region from the 0-bootstrap step
default_region = "us-central1"

github_app_installation_id = 00000000

create_repositories = true

gh_common_project_repos = {
  owner = "badal-io",
  project_repos = {
    artifacts         = "gcp-dm-bu4-prj-artifacts",
    data-governance   = "gcp-dm-bu4-prj-data-governance",
    domain-1-ingest   = "gcp-dm-bu4-prj-domain-1-ingest",
    domain-1-non-conf = "gcp-dm-bu4-prj-domain-1-non-conf",
    domain-1-conf     = "gcp-dm-bu4-prj-domain-1-conf",
    consumer-1        = "gcp-dm-bu4-prj-consumer-1",
    service-catalog   = "gcp-dm-bu4-prj-service-catalog",
  }
}

gh_artifact_repos = {
  owner = "badal-io",
  artifact_project_repos = {
    artifact-repo   = "gcp-dm-bu4-artifact-publish"
    service-catalog = "gcp-dm-bu4-service-catalog-solutions"
  }
}
