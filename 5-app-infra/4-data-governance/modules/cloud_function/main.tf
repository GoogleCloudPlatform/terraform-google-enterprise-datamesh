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
resource "google_storage_bucket_object" "function_zip" {
  name   = var.source_archive_object
  bucket = var.bucket_name
  source = var.source_path
}

resource "google_cloudfunctions2_function" "cloud_function" {
  project      = var.project_id
  location     = var.region
  name         = var.function_name
  description  = var.function_description
  kms_key_name = var.kms_key_name

  build_config {
    runtime               = var.runtime
    entry_point           = var.entry_point
    environment_variables = var.environment_variables
    service_account       = var.build_service_account_email
    source {
      storage_source {
        bucket = var.bucket_name
        object = google_storage_bucket_object.function_zip.name
      }
    }
  }

  service_config {
    available_memory      = var.function_memory
    service_account_email = var.service_account_email
    environment_variables = var.environment_variables
    ingress_settings      = var.ingress_settings
  }


  depends_on = [
    google_storage_bucket_object.function_zip
  ]
}

resource "google_cloudfunctions2_function_iam_member" "invoker_iam_member" {
  project        = var.project_id
  location       = var.region
  cloud_function = google_cloudfunctions2_function.cloud_function.name
  role           = "roles/cloudfunctions.invoker"
  member         = "serviceAccount:${var.invoker_member}"
}

resource "google_project_iam_member" "run_invoker_iam_member" {
  project = var.project_id
  role    = "roles/run.invoker"
  member  = "serviceAccount:${var.invoker_member}"
}

resource "google_bigquery_job" "create_remote_function" {
  count   = var.create_bigquery_remote_function ? 1 : 0
  project = var.project_id
  job_id  = "create_remote_function_${var.function_name}_${var.domain_name}_1"

  location = var.region

  query {
    query = templatefile("${var.template_path}/create_function.sql.tmpl", {
      project_id    = var.project_id
      region        = var.region
      connection    = var.remote_connection_name
      dataset       = var.dataset
      function_name = var.function_name
    })
    use_legacy_sql     = false
    create_disposition = ""
    write_disposition  = ""
  }
}
