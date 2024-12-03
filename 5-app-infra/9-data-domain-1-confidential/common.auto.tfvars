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

remote_state_bucket          = "REMOTE_STATE_BUCKET"
data_governance_state_bucket = "DATA_GOVERNANCE_STATE_BUCKET"

domain_name   = "domain-1"
business_unit = "business_unit_4"
business_code = "bu4"
keyring_name  = "sample-keyring"

bigquery_dataset_id_prefix                  = "confidential"
bigquery_non_confidential_dataset_id_prefix = "non_confidential"

dataflow_repository_name = "flex-templates"

dataflow_gcs_bucket_url = "UPDATE_TEMPLATE_BUCKET_URL"

confidential_datasets = [
  {
    name = "dataset"
    tables_schema = {
      "cc_data" = "Card_Type_Code:STRING,Card_Type_Full_Name:STRING,Issuing_Bank:STRING,Card_Number:STRING,Card_Holders_Name:STRING,CVV_CVV2:STRING,Issue_Date:STRING,Expiry_Date:STRING,Billing_Date:STRING,Card_PIN:STRING,Credit_Limit:STRING"
    }
  },
  {
    name = "crm"
    tables_schema = {
      "NewCust" = "action_ts:DATETIME,c_dob:DATE,c_gndr:STRING,c_id:INTEGER,c_tax_id:STRING,c_tier:STRING,c_l_name:STRING,c_f_name:STRING,c_m_name:STRING,c_adline1:STRING,c_adline2:STRING,c_zipcode:STRING,c_city:STRING,c_state_prov:STRING,c_ctry:STRING,c_prim_email:STRING,c_alt_email:STRING,c_ctry_code_1:STRING,c_area_code_1:STRING,c_local_1:STRING,c_ctry_code_2:STRING,c_area_code_2:STRING,c_local_2:STRING,c_ctry_code_3:STRING,c_area_code_3:STRING,c_local_3:STRING,c_lcl_tx_id:STRING,c_nat_tx_id:STRING,ca_id:STRING,ca_tax_st:STRING,ca_b_id:STRING,ca_name:STRING,card:STRING"
      "UpdCust" = "action_ts:DATETIME,c_id:INTEGER,c_tier:STRING,c_adline1:STRING,c_zipcode:STRING,c_city:STRING,c_state_prov:STRING,c_ctry:STRING,c_prim_email:STRING,c_phone_1_ctry_code:STRING,c_phone_1_area_code:STRING,c_phone_1_c_local:STRING,c_phone_2_ctry_code:STRING,c_phone_2_area_code:STRING,c_phone_2_c_local:STRING,c_phone_3_ctry_code:STRING,c_phone_3_area_code:STRING,c_phone_3_c_local:STRING"
    }
  }
]
