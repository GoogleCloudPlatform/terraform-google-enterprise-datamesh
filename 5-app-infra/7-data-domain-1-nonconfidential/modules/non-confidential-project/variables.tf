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

variable "remote_state_bucket" {
  type        = string
  description = "Name of the remote state bucket"
}

variable "business_unit" {
  type        = string
  description = "Business unit"
}

variable "business_code" {
  type        = string
  description = "Business code"
}
variable "domain_name" {
  type        = string
  description = "value of Data domain name"
}

variable "env" {
  type        = string
  description = "Environment"
}

variable "bigquery_dataset_id" {
  type        = string
  description = "BigQuery dataset id"
}

variable "bigquery_dataset_name" {
  type        = string
  description = "BigQuery dataset name"
  default     = null
}

variable "bigquery_description" {
  type        = string
  description = "BigQuery dataset description"
}

variable "bigquery_location" {
  type        = string
  description = "BigQuery dataset location"
  default     = "US"
}

variable "bigquery_delete_contents_on_destroy" {
  type        = bool
  description = "BigQuery dataset delete contents on destroy"
  default     = null
}

variable "bigquery_deletion_protection" {
  type        = bool
  description = "BigQuery dataset deletion protection"
  default     = false
}

variable "bigquery_default_table_expiration_ms" {
  type        = number
  description = "BigQuery dataset default table expiration in MS"
  default     = null
}

variable "bigquery_max_time_travel_hours" {
  type        = number
  description = "BigQuery dataset max time travel in hours"
  default     = null
}

variable "additional_bigquery_dataset_labels" {
  description = "Key value pairs in a map for dataset labels"
  type        = map(string)
  default     = {}
}

# Format: list(objects)
# domain: A domain to grant access to.
# group_by_email: An email address of a Google Group to grant access to.
# user_by_email:  An email address of a user to grant access to.
# special_group: A special group to grant access to.
variable "bigquery_access" {
  type        = any
  description = "An array of objects that define dataset access for one or more entities."
  default = [{
    role          = "roles/bigquery.dataOwner"
    special_group = "projectOwners"
  }]
}

variable "bigquery_tables" {
  type = list(object({
    table_id    = string,
    description = optional(string),
    table_name  = optional(string),
    schema      = string,
    clustering  = list(string),
    time_partitioning = object({
      expiration_ms            = string,
      field                    = string,
      type                     = string,
      require_partition_filter = bool,
    }),
    range_partitioning = object({
      field = string,
      range = object({
        start    = string,
        end      = string,
        interval = string,
      }),
    }),
    expiration_time = string,
    labels          = map(string),
  }))
  description = "List of BigQuery tables"
  default     = []
}

variable "bigquery_views" {
  description = "A list of objects which include view_id and view query"
  default     = []
  type = list(object({
    view_id        = string,
    description    = optional(string),
    query          = string,
    use_legacy_sql = bool,
    labels         = map(string),
  }))
}

variable "biugquery_materialized_views" {
  description = "A list of objects which include view_id and view query"
  default     = []
  type = list(object({
    view_id             = string,
    description         = optional(string),
    query               = string,
    enable_refresh      = bool,
    refresh_interval_ms = string,
    clustering          = list(string),
    time_partitioning = object({
      expiration_ms            = string,
      field                    = string,
      type                     = string,
      require_partition_filter = bool,
    }),
    range_partitioning = object({
      field = string,
      range = object({
        start    = string,
        end      = string,
        interval = string,
      }),
    }),
    expiration_time = string,
    labels          = map(string),
  }))
}

variable "bigquery_external_tables" {
  description = "A list of objects which include table_id, expiration_time, external_data_configuration, and labels."
  default     = []
  type = list(object({
    table_id              = string,
    description           = optional(string),
    autodetect            = bool,
    compression           = string,
    ignore_unknown_values = bool,
    max_bad_records       = number,
    schema                = string,
    source_format         = string,
    source_uris           = list(string),
    csv_options = object({
      quote                 = string,
      allow_jagged_rows     = bool,
      allow_quoted_newlines = bool,
      encoding              = string,
      field_delimiter       = string,
      skip_leading_rows     = number,
    }),
    google_sheets_options = object({
      range             = string,
      skip_leading_rows = number,
    }),
    hive_partitioning_options = object({
      mode              = string,
      source_uri_prefix = string,
    }),
    expiration_time = string,
    labels          = map(string),
  }))
}

variable "bigquery_routines" {
  description = "A list of objects which include routine_id, routine_type, routine_language, definition_body, return_type, routine_description and arguments."
  default     = []
  type = list(object({
    routine_id      = string,
    routine_type    = string,
    language        = string,
    definition_body = string,
    return_type     = string,
    description     = string,
    arguments = list(object({
      name          = string,
      data_type     = string,
      argument_kind = string,
      mode          = string,
    })),
  }))
}

variable "keyring_region" {
  description = "Keyring region"
  type        = string
  default     = "us-central1"
}
