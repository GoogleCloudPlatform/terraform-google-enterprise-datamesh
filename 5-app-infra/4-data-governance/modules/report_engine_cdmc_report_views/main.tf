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


// This module is used to create views for the Report Engine.
// Terraform loops do not work in this case.  The views need to be created in a sequence that relies on the previous
// view being created.  This is a limitation of Terraform.

resource "time_sleep" "wait_10_seconds" {
  create_duration = "10s"
}

resource "google_bigquery_table" "last_run_data_assets" {
  dataset_id = var.dataset_id
  table_id   = "_last_run_data_assets"
  project    = var.project_id

  view {
    query = templatefile("${path.module}/../../static_data/dashboard_views/cdmc_report/01-cdmc_report__last_run_data_assets.sql", {
      project_id_gov = var.project_id,
      environment    = var.environment,
      region         = var.region
    })
    use_legacy_sql = false
  }
}

resource "google_bigquery_table" "last_run_findings_detail" {
  dataset_id = var.dataset_id
  table_id   = "_last_run_findings_detail"
  project    = var.project_id

  view {
    query = templatefile("${path.module}/../../static_data/dashboard_views/cdmc_report/02-cdmc_report__last_run_findings_detail.sql", {
      project_id_gov = var.project_id,
      environment    = var.environment,
      region         = var.region
    })
    use_legacy_sql = false
  }

  depends_on = [google_bigquery_table.last_run_data_assets, time_sleep.wait_10_seconds]
}

resource "google_bigquery_table" "last_run_findings_summary" {
  dataset_id = var.dataset_id
  table_id   = "_last_run_findings_summary"
  project    = var.project_id

  view {
    query = templatefile("${path.module}/../../static_data/dashboard_views/cdmc_report/03-cdmc_report__last_run_findings_summary.sql", {
      project_id_gov = var.project_id,
      environment    = var.environment,
      region         = var.region
    })
    use_legacy_sql = false
  }

  depends_on = [google_bigquery_table.last_run_findings_detail, time_sleep.wait_10_seconds]
}

resource "google_bigquery_table" "last_run_findings_summary_alldata" {
  dataset_id = var.dataset_id
  table_id   = "_last_run_findings_summary_alldata"
  project    = var.project_id

  view {
    query = templatefile("${path.module}/../../static_data/dashboard_views/cdmc_report/04-cdmc_report__last_run_findings_summary_alldata.sql", {
      project_id_gov = var.project_id,
      environment    = var.environment,
      region         = var.region
    })
    use_legacy_sql = false
  }

  depends_on = [google_bigquery_table.last_run_findings_summary, time_sleep.wait_10_seconds]
}

resource "google_bigquery_table" "last_run_dataset_stats" {
  dataset_id = var.dataset_id
  table_id   = "_last_run_dataset_stats"
  project    = var.project_id

  view {
    query = templatefile("${path.module}/../../static_data/dashboard_views/cdmc_report/05-cdmc_report__last_run_dataset_stats.sql", {
      project_id_gov = var.project_id,
      environment    = var.environment,
      region         = var.region
    })
    use_legacy_sql = false
  }

  depends_on = [google_bigquery_table.last_run_findings_summary_alldata, time_sleep.wait_10_seconds]
}

resource "google_bigquery_table" "last_run_metadata" {
  dataset_id = var.dataset_id
  table_id   = "_last_run_metadata"
  project    = var.project_id

  view {
    query = templatefile("${path.module}/../../static_data/dashboard_views/cdmc_report/06-cdmc_report__last_run_metadata.sql", {
      project_id_gov = var.project_id,
      environment    = var.environment,
      region         = var.region
    })
    use_legacy_sql = false
  }

  depends_on = [google_bigquery_table.last_run_dataset_stats, time_sleep.wait_10_seconds]
}

resource "google_bigquery_table" "information_schema_view" {
  dataset_id = var.dataset_id
  table_id   = "_information_schema_view"
  project    = var.project_id

  view {
    query = templatefile("${path.module}/../../static_data/dashboard_views/cdmc_report/07-cdmc_report__information_schema_view.sql", {
      project_id_gov = var.project_id,
      environment    = var.environment,
      region         = var.region
    })
    use_legacy_sql = false
  }

  depends_on = [google_bigquery_table.last_run_metadata, time_sleep.wait_10_seconds]
}
