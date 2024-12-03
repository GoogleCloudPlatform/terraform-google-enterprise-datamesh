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

  richtext_fields = flatten([
    for template in var.datacatalog_templates : [
      for field in yamldecode(file(template)).template[0].fields :
      {
        template_name = yamldecode(file(template)).template[0].name
        description   = field.description
        display       = field.display
        required      = lookup(field, "required", false)
        field         = field.field
        order         = field.order
      } if field.type == "richtext"
    ]
  ])

}

data "google_client_config" "account" {}

resource "random_string" "suffix" {
  length  = 4
  special = false
  upper   = false
}

resource "google_data_catalog_taxonomy" "secure_taxonomy" {
  provider = google-beta

  project                = var.project_id
  region                 = var.location
  display_name           = var.taxonomy_display_name
  description            = "Taxonomy created for Sample Sensitive Data"
  activated_policy_types = ["FINE_GRAINED_ACCESS_CONTROL"]

}


resource "google_data_catalog_policy_tag" "sensitive_tags" {
  provider = google-beta
  for_each = var.sensitive_tags

  taxonomy     = google_data_catalog_taxonomy.secure_taxonomy.id
  display_name = each.value["display_name"]
  description  = each.value["display_name"]
}

resource "google_bigquery_datapolicy_data_policy" "masking_policy" {
  for_each = { for tag, value in var.sensitive_tags : tag => value }
  provider = google-beta

  project          = var.project_id
  location         = var.location
  data_policy_id   = replace("${each.key}_${var.data_domain_name}_${var.environment}", "-", "_")
  policy_tag       = google_data_catalog_policy_tag.sensitive_tags[each.key].name
  data_policy_type = "DATA_MASKING_POLICY"

  data_masking_policy {
    predefined_expression = each.value.masking_policy
  }
}

resource "google_data_catalog_tag_template" "tag_template" {
  for_each = { for template in var.datacatalog_templates : yamldecode(file(template)).template[0].name => yamldecode(file(template)).template[0] if var.environment == "production" }
  provider = google-beta

  project         = var.project_id
  region          = var.location
  display_name    = each.value.display_name
  tag_template_id = each.value.name
  force_delete    = true

  dynamic "fields" {
    for_each = [for field in each.value.fields : field if field.type != "richtext"]
    content {
      field_id     = fields.value.field
      description  = fields.value.description
      display_name = fields.value.display
      is_required  = lookup(fields.value, "required", false)
      order        = lookup(fields.value, "order", 0)
      type {
        primitive_type = contains(["DOUBLE", "STRING", "BOOL", "TIMESTAMP"], upper(fields.value.type)) ? upper(fields.value.type) : null
        dynamic "enum_type" {
          for_each = fields.value.type == "enum" ? [fields.value] : []
          content {
            dynamic "allowed_values" {
              for_each = toset([for enum_value in split("|", fields.value.values) : enum_value])
              content {
                display_name = allowed_values.key
              }
            }
          }
        }
      }
    }
  }
  lifecycle {
    ignore_changes = [fields]
  }
}

// N.B. This is a temporary solution. Tag Template resource (above) currently does not support rich text as a primitive
resource "terracurl_request" "name" {
  provider = terracurl
  for_each = var.environment != "production" ? {} : { for data in local.richtext_fields : "${data.template_name}-${data.field}" => data }

  name   = each.key
  method = "POST"
  headers = {
    Authorization = "Bearer ${data.google_client_config.account.access_token}"
    Content-Type  = "application/json"
  }
  url            = "https://datacatalog.googleapis.com/v1/${google_data_catalog_tag_template.tag_template[each.value.template_name].name}/fields?tagTemplateFieldId=${each.value.field}"
  response_codes = [200, 204, 409]
  request_body   = <<EOF
  {
    "type": {
      "primitiveType": "RICHTEXT"
    },
    "description": "${each.value.description}",
    "displayName": "${each.value.display}",
    "isRequired": ${lookup(each.value, "required", false)},
    "name": "${each.value.field}",
    "order": ${each.value.order}
  }
  EOF

  destroy_method = "DELETE"
  destroy_url    = "https://datacatalog.googleapis.com/v1/${google_data_catalog_tag_template.tag_template[each.value.template_name].name}/fields/${each.value.field}"
  destroy_headers = {
    Authorization = "Bearer ${data.google_client_config.account.access_token}"
  }
  destroy_response_codes = [200, 204]
  destroy_timeout        = 300

  depends_on = [google_data_catalog_tag_template.tag_template]

  lifecycle {
    ignore_changes = [headers]
  }

}
