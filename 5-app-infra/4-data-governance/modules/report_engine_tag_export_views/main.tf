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

resource "google_bigquery_table" "catalog_report_column_dq_report" {
  dataset_id = var.dataset_id
  table_id   = "catalog_report_column_dq_report"
  project    = var.project_id
  view {
    query = templatefile("${path.module}/../../static_data/dashboard_views/tag_export/01-tag_exports__catalog_report_column_dq_report.sql", {
      project_id_gov = var.project_id,
    })
    use_legacy_sql = false
  }
}

resource "google_bigquery_table" "catalog_report_column_security_report" {
  dataset_id = var.dataset_id
  table_id   = "catalog_report_column_security_report"
  project    = var.project_id
  view {
    query = templatefile("${path.module}/../../static_data/dashboard_views/tag_export/02-tag_exports__catalog_report_column_security_report.sql", {
      project_id_gov = var.project_id,
    })
    use_legacy_sql = false
  }
  depends_on = [google_bigquery_table.catalog_report_column_dq_report, time_sleep.wait_10_seconds]
}

resource "google_bigquery_table" "catalog_report_table_cdmc_controls_heatmap" {
  dataset_id = var.dataset_id
  table_id   = "catalog_report_table_cdmc_controls_heatmap"
  project    = var.project_id
  view {
    query = templatefile("${path.module}/../../static_data/dashboard_views/tag_export/03-tag_exports__catalog_report_table_cdmc_controls_heatmap.sql", {
      project_id_gov = var.project_id,
    })
    use_legacy_sql = false
  }
  depends_on = [google_bigquery_table.catalog_report_column_security_report, time_sleep.wait_10_seconds]
}

resource "google_bigquery_table" "catalog_report_table_cost_report" {
  dataset_id = var.dataset_id
  table_id   = "catalog_report_table_cost_report"
  project    = var.project_id
  view {
    query = templatefile("${path.module}/../../static_data/dashboard_views/tag_export/04-tag_exports__catalog_report_table_cost_report.sql", {
      project_id_gov = var.project_id,
    })
    use_legacy_sql = false
  }
  depends_on = [google_bigquery_table.catalog_report_table_cdmc_controls_heatmap, time_sleep.wait_10_seconds]
}

resource "google_bigquery_table" "catalog_report_table_dq_report" {
  dataset_id = var.dataset_id
  table_id   = "catalog_report_table_dq_report"
  project    = var.project_id
  view {
    query = templatefile("${path.module}/../../static_data/dashboard_views/tag_export/05-tag_exports__catalog_report_table_dq_report.sql", {
      project_id_gov = var.project_id,
    })
    use_legacy_sql = false
  }
  depends_on = [google_bigquery_table.catalog_report_table_cost_report, time_sleep.wait_10_seconds]
}

resource "google_bigquery_table" "catalog_report_table_ia_report" {
  dataset_id = var.dataset_id
  table_id   = "catalog_report_table_ia_report"
  project    = var.project_id
  view {
    query = templatefile("${path.module}/../../static_data/dashboard_views/tag_export/06-tag_exports__catalog_report_table_ia_report.sql", {
      project_id_gov = var.project_id,
    })
    use_legacy_sql = false
  }
  depends_on = [google_bigquery_table.catalog_report_table_dq_report, time_sleep.wait_10_seconds]
}

resource "google_bigquery_table" "catalog_report_table_retention_report" {
  dataset_id = var.dataset_id
  table_id   = "catalog_report_table_retention_report"
  project    = var.project_id
  view {
    query = templatefile("${path.module}/../../static_data/dashboard_views/tag_export/07-tag_exports__catalog_report_table_retention_report.sql", {
      project_id_gov = var.project_id,
    })
    use_legacy_sql = false
  }
  depends_on = [google_bigquery_table.catalog_report_table_ia_report, time_sleep.wait_10_seconds]
}

resource "google_bigquery_table" "catalog_report_table_security_report" {
  dataset_id = var.dataset_id
  table_id   = "catalog_report_table_security_report"
  project    = var.project_id
  view {
    query = templatefile("${path.module}/../../static_data/dashboard_views/tag_export/08-tag_exports__catalog_report_table_security_report.sql", {
      project_id_gov = var.project_id,
    })
    use_legacy_sql = false
  }
  depends_on = [google_bigquery_table.catalog_report_table_retention_report, time_sleep.wait_10_seconds]
}
