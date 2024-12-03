<!-- BEGIN_TF_DOCS -->
Copyright 2024 Google LLC

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | 6.10.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_bigquery_table.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/bigquery_table) | resource |
| [google_kms_crypto_key.key](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/kms_crypto_key) | data source |
| [google_kms_key_ring.kms](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/kms_key_ring) | data source |
| [google_project.project](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/project) | data source |
| [google_projects.kms](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/projects) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_data_domain"></a> [data\_domain](#input\_data\_domain) | Data Domain name. | `string` | `"domain-1"` | no |
| <a name="input_dataset_id"></a> [dataset\_id](#input\_dataset\_id) | The ID of the BigQuery dataset where the table will be created. | `string` | n/a | yes |
| <a name="input_deletion_protection"></a> [deletion\_protection](#input\_deletion\_protection) | Whether or not to allow deletion of tables and external tables defined by this module. Can be overriden by table-level deletion\_protection configuration. | `bool` | `false` | no |
| <a name="input_expiration_time"></a> [expiration\_time](#input\_expiration\_time) | The expiration time for the table in RFC 3339 format. | `string` | `null` | no |
| <a name="input_keyring_name"></a> [keyring\_name](#input\_keyring\_name) | Name of the keyring | `string` | `"sample-keyring"` | no |
| <a name="input_labels"></a> [labels](#input\_labels) | Key value pairs in a map for dataset labels | `map(string)` | `{}` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Optional Project ID. | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | The resource region, one of [us-central1, us-east4]. | `string` | `"us-central1"` | no |
| <a name="input_schema"></a> [schema](#input\_schema) | The schema for the BigQuery table in JSON format. | `string` | n/a | yes |
| <a name="input_table_id"></a> [table\_id](#input\_table\_id) | The ID of the BigQuery table to create. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bigquery_table"></a> [bigquery\_table](#output\_bigquery\_table) | The created bigquery table |
<!-- END_TF_DOCS -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| data\_domain | Data Domain name. | `string` | `"domain-1"` | no |
| dataset\_id | The ID of the BigQuery dataset where the table will be created. | `string` | n/a | yes |
| deletion\_protection | Whether or not to allow deletion of tables and external tables defined by this module. Can be overriden by table-level deletion\_protection configuration. | `bool` | `false` | no |
| expiration\_time | The expiration time for the table in RFC 3339 format. | `string` | `null` | no |
| keyring\_name | Name of the keyring | `string` | `"sample-keyring"` | no |
| labels | Key value pairs in a map for dataset labels | `map(string)` | `{}` | no |
| project\_id | Optional Project ID. | `string` | `null` | no |
| region | The resource region, one of [us-central1, us-east4]. | `string` | `"us-central1"` | no |
| schema | The schema for the BigQuery table in JSON format. | `string` | n/a | yes |
| table\_id | The ID of the BigQuery table to create. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| bigquery\_table | The created bigquery table |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->