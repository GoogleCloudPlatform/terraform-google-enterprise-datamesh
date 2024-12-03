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

remote_state_bucket = "REMOTE_STATE_BUCKET"

environment = "common"

region = "us-central1"

business_unit = "business_unit_4"

ddl_tables = { // must have a corresponding json file under static_data/ddl_tables/
  data_classification = [
    "infotype_classification",
    "infotype_selection"
  ]
  data_retention = [
    "retention_policy"
  ]
  entitlement_management = [
    "consumer_agreement",
    "data_asset",
    "provider_agreement",
    "use_purpose"
  ]
  impact_assessment = [
    "asset_ia_details",
    "ia_policy"
  ]
  security_policy = [
    "default_methods",
    "permitted_methods"
  ]
}

deidentify_field_transformations = [
  "Card_Number",
  "Card_PIN",
  "c_tax_id",
  "c_state_prov",
]


dlp_job_inspect_datasets = [
  {
    environment        = "nonproduction"
    domain_name        = "domain-1"
    business_code      = "bu4"
    inspection_dataset = "bu4_non_confidential_dataset_nonproduction"
    resulting_dataset  = "bu4_non_confidential_dataset_nonproduction_dlp"
    owner_information = {
      name               = "John Doe"
      email              = "7l6dM@example.com"
      is_sensitive       = false
      sensitive_category = "No"
      is_authoritative   = true
    }
    inspecting_table_ids = [
      "cc_data",
    ]
    inspect_config_info_types = [
      "CREDIT_CARD_NUMBER",
      "EMAIL_ADDRESS",
      "STREET_ADDRESS",
      "PHONE_NUMBER",
      "PERSON_NAME",
      "FIRST_NAME",
      "LAST_NAME",
      "GENDER",
      "DATE_OF_BIRTH",
      "AGE",
      "ETHNIC_GROUP",
      "LOCATION_COORDINATES",
      "IP_ADDRESS",
    ]
  },
  {
    environment        = "nonproduction"
    domain_name        = "domain-1"
    business_code      = "bu4"
    inspection_dataset = "bu4_non_confidential_crm_nonproduction"
    resulting_dataset  = "bu4_non_confidential_crm_nonproduction_dlp"
    owner_information = {
      name               = "Jane Doe"
      email              = "32NkA@example.com"
      is_sensitive       = true
      sensitive_category = "No"
      is_authoritative   = true
    }
    inspecting_table_ids = [
      "NewCust",
      "UpdCust"
    ]
    inspect_config_info_types = [
      "CREDIT_CARD_NUMBER",
      "EMAIL_ADDRESS",
      "STREET_ADDRESS",
      "PHONE_NUMBER",
      "PERSON_NAME",
      "FIRST_NAME",
      "LAST_NAME",
      "GENDER",
      "DATE_OF_BIRTH",
      "AGE",
      "ETHNIC_GROUP",
      "LOCATION_COORDINATES",
      "IP_ADDRESS",
    ]
  }
]

data_catalog_sensitive_tags = {
  personal_identifiable_information_policy = {
    display_name   = "Personal_Identifiable_Information"
    masking_policy = "SHA256"
  }
  personal_information_policy = {
    display_name   = "Personal_Information"
    masking_policy = "DEFAULT_MASKING_VALUE"
  }
  sensitive_personal_identifiable_information_policy = {
    display_name   = "Sensitive_Personal_Identifiable_Information"
    masking_policy = "ALWAYS_NULL"
  }
  sensitive_personal_information_policy = {
    display_name   = "Sensitive_Personal_Information"
    masking_policy = "DEFAULT_MASKING_VALUE"
  }
}

record_manager_config = {
  template_id               = "cdmc_controls"
  retention_period_field    = "retention_period"
  expiration_action_field   = "expiration_action"
  snapshot_dataset          = "snapshots"
  snapshot_retention_period = 30
  archives_bucket           = "archived_assets"
  export_format             = "parquet"
  archives_dataset          = "archives"
  mode                      = "apply"
}

record_manager_image_tag         = "development"
tag_engine_image_tag             = "development"
report_engine_image_tag          = "development"
data_access_management_image_tag = "development"
data_quality_image_tag           = "development"
