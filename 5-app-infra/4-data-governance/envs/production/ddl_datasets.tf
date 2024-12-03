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

##########################################
# Create bucket to store DDL data
##########################################

resource "google_storage_bucket" "ddl_data_bucket" {
  force_destroy               = true
  labels                      = local.data_labels
  location                    = var.region
  name                        = "${local.data_governance_project_id}-ddl-data"
  project                     = local.data_governance_project_id
  public_access_prevention    = "enforced"
  uniform_bucket_level_access = true
}

resource "google_storage_bucket_iam_member" "ddl_data_bucket" {
  for_each = toset(local.ddl_data_access)
  bucket   = google_storage_bucket.ddl_data_bucket.name
  role     = "roles/storage.legacyBucketReader"
  member   = each.key
}

resource "google_storage_bucket_iam_member" "ddl_data_object" {
  for_each = toset(local.ddl_data_access)
  bucket   = google_storage_bucket.ddl_data_bucket.name
  role     = "roles/storage.legacyObjectReader"
  member   = each.key
}

############################################
# Development Datasets
############################################

resource "google_storage_bucket_object" "ddl_data_development" {
  for_each = merge(
    flatten([
      for domain, project in local.data_domain_non_conf_projects_dev : [
        for dataset, tables in var.ddl_tables : [
          for table in tables : [
            for inspection in var.dlp_job_inspect_datasets : [
              for inspection_table in inspection.inspecting_table_ids : {
                "${domain}/${dataset}/${table}/${inspection.inspection_dataset}/${inspection_table}" = {
                  domain             = domain,
                  project_id         = project.project_id,
                  dataset            = dataset,
                  table              = table,
                  inspection_dataset = inspection.inspection_dataset
                  inspection_table   = inspection_table
                  inspection_owner   = inspection.owner_information
                }
              } if inspection.environment == "development"
            ]
          ]
        ]
      ]
    ])...
  )

  bucket = google_storage_bucket.ddl_data_bucket.name
  name   = "development/${each.value.domain}/${each.value.dataset}/${each.value.inspection_dataset}/${each.value.table}_${each.value.inspection_table}.json"
  content = templatefile("${path.module}/../../static_data/ddl_tables/${each.value.domain}/${each.value.dataset}/${each.value.table}.json", {
    PROJECT_ID_DATA    = each.value.project_id
    dataset_id         = each.value.inspection_dataset
    table_id           = each.value.inspection_table
    data_owner_email   = each.value.inspection_owner["email"]
    data_owner_name    = each.value.inspection_owner["name"]
    is_sensitive       = each.value.inspection_owner["is_sensitive"]
    sensitive_category = each.value.inspection_owner["sensitive_category"]
    is_authoritative   = each.value.inspection_owner["is_authoritative"]
  })
}

module "bigquery_ddl_datasets_development" {
  for_each = merge(flatten([
    for domain, project in local.data_domain_non_conf_projects_dev : [
      for dataset, tables in var.ddl_tables : [
        for inspection in var.dlp_job_inspect_datasets : {
          "${domain}/${dataset}" = {
            domain             = domain,
            project_id         = project.project_id,
            dataset            = dataset,
            tables             = tables
            inspection_dataset = inspection.inspection_dataset
          }
        } if inspection.environment == "development"
      ]
    ]
  ])...)

  source = "../../modules/bigquery"

  dataset_id                 = "${each.value.dataset}_${replace(each.value.domain, "-", "_")}_dev"
  dataset_labels             = local.data_labels
  dataset_name               = "${each.value.dataset}_${replace(each.value.domain, "-", "_")}_dev"
  delete_contents_on_destroy = true
  encryption_key             = local.bq_data_quality_kms_key

  external_tables = [for table in each.value.tables : {
    autodetect    = true
    source_format = "NEWLINE_DELIMITED_JSON"
    source_uris = flatten([
      for dataset in var.dlp_job_inspect_datasets : [
        for inspection_table in dataset.inspecting_table_ids : [
          "gs://${google_storage_bucket.ddl_data_bucket.name}/${google_storage_bucket_object.ddl_data_nonproduction["${each.key}/${table}/${dataset.inspection_dataset}/${inspection_table}"].name}"
        ]
      ] if dataset.domain_name == each.value.domain
    ])
    table_id = table
  }]
  views = each.value.dataset == "entitlement_management" ? [
    {
      view_id        = "_information_schema_view"
      use_legacy_sql = false
      query = templatefile("${path.module}/../../static_data/ddl_tables/${each.value.domain}/entitlement_management/view/information_schema_view.sql", {
        region = var.region
      })
      labels = {
        env = "cdmc"
      }
    }

  ] : []
  location   = var.region
  project_id = local.data_governance_project_id
}


############################################
# Non Production Datasets
############################################

resource "google_storage_bucket_object" "ddl_data_nonproduction" {
  for_each = merge(
    flatten([
      for domain, project in local.data_domain_non_conf_projects_nonp : [
        for dataset, tables in var.ddl_tables : [
          for table in tables : [
            for inspection in var.dlp_job_inspect_datasets : [
              for inspection_table in inspection.inspecting_table_ids : {
                "${domain}/${dataset}/${table}/${inspection.inspection_dataset}/${inspection_table}" = {
                  domain             = domain,
                  project_id         = project.project_id,
                  dataset            = dataset,
                  table              = table,
                  inspection_dataset = inspection.inspection_dataset
                  inspection_table   = inspection_table
                  inspection_owner   = inspection.owner_information
                }
              } if inspection.environment == "nonproduction"
            ]
          ]
        ]
      ]
    ])...
  )

  bucket = google_storage_bucket.ddl_data_bucket.name
  name   = each.value.table == "asset_ia_details" ? "nonproduction/${each.value.domain}/${each.value.dataset}/${each.value.inspection_dataset}/${each.value.table}_${each.value.inspection_table}.json" : each.value.table == "data_asset" || each.value.table == "provider_agreement" || each.value.table == "use_purpose" ? "nonproduction/${each.value.domain}/${each.value.dataset}/${each.value.inspection_dataset}/${each.value.table}.json" : "nonproduction/${each.value.domain}/${each.value.dataset}/${each.value.table}.json"
  content = templatefile("${path.module}/../../static_data/ddl_tables/${each.value.domain}/${each.value.dataset}/${each.value.table}.json", {
    PROJECT_ID_DATA    = each.value.project_id
    dataset_id         = each.value.inspection_dataset
    table_id           = each.value.inspection_table
    data_owner_email   = each.value.inspection_owner["email"]
    data_owner_name    = each.value.inspection_owner["name"]
    is_sensitive       = each.value.inspection_owner["is_sensitive"]
    sensitive_category = each.value.inspection_owner["sensitive_category"]
    is_authoritative   = each.value.inspection_owner["is_authoritative"]
  })
}

module "bigquery_ddl_datasets_nonproduction" {
  for_each = merge(flatten([
    for domain, project in local.data_domain_non_conf_projects_nonp : [
      for dataset, tables in var.ddl_tables : [
        for inspection in var.dlp_job_inspect_datasets : {
          "${domain}/${dataset}" = {
            domain             = domain,
            project_id         = project.project_id,
            dataset            = dataset,
            tables             = tables
            inspection_dataset = inspection.inspection_dataset
          }
        } if inspection.environment == "nonproduction"
      ]
    ]
  ])...)

  source = "../../modules/bigquery"

  dataset_id                 = "${each.value.dataset}_${replace(each.value.domain, "-", "_")}_nonp"
  dataset_labels             = local.data_labels
  dataset_name               = "${each.value.dataset}_${replace(each.value.domain, "-", "_")}_nonp"
  delete_contents_on_destroy = true
  encryption_key             = local.bq_data_quality_kms_key

  external_tables = [for table in each.value.tables : {
    autodetect    = true
    source_format = "NEWLINE_DELIMITED_JSON"
    source_uris = distinct(flatten([
      for dataset in var.dlp_job_inspect_datasets : [
        for inspection_table in dataset.inspecting_table_ids : [
          "gs://${google_storage_bucket.ddl_data_bucket.name}/${google_storage_bucket_object.ddl_data_nonproduction["${each.key}/${table}/${dataset.inspection_dataset}/${inspection_table}"].name}"
        ]
      ] if dataset.domain_name == each.value.domain
    ]))
    table_id = table
  }]

  views = each.value.dataset == "entitlement_management" ? [
    {
      view_id        = "_information_schema_view"
      use_legacy_sql = false
      query = templatefile("${path.module}/../../static_data/ddl_tables/${each.value.domain}/entitlement_management/view/information_schema_view.sql", {
        region = var.region
      })
      labels = {
        env = "cdmc"
      }
    }

  ] : []

  location   = var.region
  project_id = local.data_governance_project_id
}


############################################
# Production Datasets
############################################

resource "google_storage_bucket_object" "ddl_data_production" {
  for_each = merge(
    flatten([
      for domain, project in local.data_domain_non_conf_projects_prod : [
        for dataset, tables in var.ddl_tables : [
          for table in tables : [
            for inspection in var.dlp_job_inspect_datasets : [
              for inspection_table in inspection.inspecting_table_ids : {
                "${domain}/${dataset}/${table}/${inspection.inspection_dataset}/${inspection_table}" = {
                  domain             = domain,
                  project_id         = project.project_id,
                  dataset            = dataset,
                  table              = table,
                  inspection_dataset = inspection.inspection_dataset
                  inspection_table   = inspection_table
                  inspection_owner   = inspection.owner_information
                }
              } if inspection.environment == "production"
            ]
          ]
        ]
      ]
    ])...
  )

  bucket = google_storage_bucket.ddl_data_bucket.name
  name   = each.value.table == "asset_ia_details" ? "production/${each.value.domain}/${each.value.dataset}/${each.value.inspection_dataset}/${each.value.table}_${each.value.inspection_table}.json" : each.value.table == "data_asset" || each.value.table == "provider_agreement" || each.value.table == "use_purpose" ? "nonproduction/${each.value.domain}/${each.value.dataset}/${each.value.inspection_dataset}/${each.value.table}.json" : "nonproduction/${each.value.domain}/${each.value.dataset}/${each.value.table}.json"
  content = templatefile("${path.module}/../../static_data/ddl_tables/${each.value.domain}/${each.value.dataset}/${each.value.table}.json", {
    PROJECT_ID_DATA    = each.value.project_id
    dataset_id         = each.value.inspection_dataset
    table_id           = each.value.inspection_table
    data_owner_email   = each.value.inspection_owner["email"]
    data_owner_name    = each.value.inspection_owner["name"]
    is_sensitive       = each.value.inspection_owner["is_sensitive"]
    sensitive_category = each.value.inspection_owner["sensitive_category"]
    is_authoritative   = each.value.inspection_owner["is_authoritative"]
  })
}

module "bigquery_ddl_datasets_production" {
  for_each = merge(flatten([
    for domain, project in local.data_domain_non_conf_projects_prod : [
      for dataset, tables in var.ddl_tables : [
        for inspection in var.dlp_job_inspect_datasets : {
          "${domain}/${dataset}" = {
            domain             = domain,
            project_id         = project.project_id,
            dataset            = dataset,
            tables             = tables
            inspection_dataset = inspection.inspection_dataset
          }
        } if inspection.environment == "production"
      ]
    ]
  ])...)

  source = "../../modules/bigquery"

  dataset_id                 = "${each.value.dataset}_${replace(each.value.domain, "-", "_")}_prod"
  dataset_labels             = local.data_labels
  dataset_name               = "${each.value.dataset}_${replace(each.value.domain, "-", "_")}_prod"
  delete_contents_on_destroy = true
  encryption_key             = local.bq_data_quality_kms_key

  external_tables = [for table in each.value.tables : {
    autodetect    = true
    source_format = "NEWLINE_DELIMITED_JSON"
    source_uris = flatten([
      for dataset in var.dlp_job_inspect_datasets : [
        for inspection_table in dataset.inspecting_table_ids : [
          "gs://${google_storage_bucket.ddl_data_bucket.name}/${google_storage_bucket_object.ddl_data_nonproduction["${each.key}/${table}/${dataset.inspection_dataset}/${inspection_table}"].name}"
        ]
      ] if dataset.domain_name == each.value.domain
    ])
    table_id = table
  }]

  views = each.value.dataset == "entitlement_management" ? [
    {
      view_id        = "_information_schema_view"
      use_legacy_sql = false
      query = templatefile("${path.module}/../../static_data/ddl_tables/${each.value.domain}/entitlement_management/view/information_schema_view.sql", {
        region = var.region
      })
      labels = {
        env = "cdmc"
      }
    }

  ] : []

  location   = var.region
  project_id = local.data_governance_project_id
}
