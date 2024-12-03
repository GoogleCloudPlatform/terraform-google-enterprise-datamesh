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

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 5.0, < 6.0 |
| <a name="requirement_google-beta"></a> [google-beta](#requirement\_google-beta) | >= 5.0, < 6.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | >= 5.0, < 6.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_bigquery_dataset.main](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/bigquery_dataset) | resource |
| [google_kms_crypto_key.key](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/kms_crypto_key) | data source |
| [google_kms_key_ring.kms](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/kms_key_ring) | data source |
| [google_project.project](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/project) | data source |
| [google_projects.kms](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/projects) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access"></a> [access](#input\_access) | An array of objects that define dataset access for one or more entities. | `any` | <pre>[<br>  {<br>    "role": "roles/bigquery.dataOwner",<br>    "special_group": "projectOwners"<br>  }<br>]</pre> | no |
| <a name="input_data_domain"></a> [data\_domain](#input\_data\_domain) | Data Domain name. | `string` | `"domain-1"` | no |
| <a name="input_dataset_id"></a> [dataset\_id](#input\_dataset\_id) | Unique ID for the dataset being provisioned. | `string` | n/a | yes |
| <a name="input_dataset_labels"></a> [dataset\_labels](#input\_dataset\_labels) | Key value pairs in a map for dataset labels | `map(string)` | `{}` | no |
| <a name="input_dataset_name"></a> [dataset\_name](#input\_dataset\_name) | Friendly name for the dataset being provisioned. | `string` | `null` | no |
| <a name="input_default_table_expiration_ms"></a> [default\_table\_expiration\_ms](#input\_default\_table\_expiration\_ms) | TTL of tables using the dataset in MS | `number` | `null` | no |
| <a name="input_delete_contents_on_destroy"></a> [delete\_contents\_on\_destroy](#input\_delete\_contents\_on\_destroy) | (Optional) If set to true, delete all the tables in the dataset when destroying the resource; otherwise, destroying the resource will fail if tables are present. | `bool` | `null` | no |
| <a name="input_description"></a> [description](#input\_description) | Dataset description. | `string` | `null` | no |
| <a name="input_keyring_name"></a> [keyring\_name](#input\_keyring\_name) | Name of the keyring | `string` | `"sample-keyring"` | no |
| <a name="input_max_time_travel_hours"></a> [max\_time\_travel\_hours](#input\_max\_time\_travel\_hours) | Defines the time travel window in hours | `number` | `168` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Optional Project ID. | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | The resource region, one of [us-central1, us-east4]. | `string` | `"us-central1"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bigquery_dataset"></a> [bigquery\_dataset](#output\_bigquery\_dataset) | The created bigquery dataset |
<!-- END_TF_DOCS -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| access | An array of objects that define dataset access for one or more entities. | `any` | <pre>[<br>  {<br>    "role": "roles/bigquery.dataOwner",<br>    "special_group": "projectOwners"<br>  }<br>]</pre> | no |
| data\_domain | Data Domain name. | `string` | `"domain-1"` | no |
| dataset\_id | Unique ID for the dataset being provisioned. | `string` | n/a | yes |
| dataset\_labels | Key value pairs in a map for dataset labels | `map(string)` | `{}` | no |
| dataset\_name | Friendly name for the dataset being provisioned. | `string` | `null` | no |
| default\_table\_expiration\_ms | TTL of tables using the dataset in MS | `number` | `null` | no |
| delete\_contents\_on\_destroy | (Optional) If set to true, delete all the tables in the dataset when destroying the resource; otherwise, destroying the resource will fail if tables are present. | `bool` | `null` | no |
| description | Dataset description. | `string` | `null` | no |
| keyring\_name | Name of the keyring | `string` | `"sample-keyring"` | no |
| max\_time\_travel\_hours | Defines the time travel window in hours | `number` | `168` | no |
| project\_id | Optional Project ID. | `string` | `null` | no |
| region | The resource region, one of [us-central1, us-east4]. | `string` | `"us-central1"` | no |

## Outputs

| Name | Description |
|------|-------------|
| bigquery\_dataset | The created bigquery dataset |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->