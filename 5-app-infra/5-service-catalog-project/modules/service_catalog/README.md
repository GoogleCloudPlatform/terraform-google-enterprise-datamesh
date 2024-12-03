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
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 5.0 |
| <a name="requirement_google-beta"></a> [google-beta](#requirement\_google-beta) | >= 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | >= 5.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_cloudbuild_trigger.solutions](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloudbuild_trigger) | resource |
| [google_cloudbuildv2_connection.github](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloudbuildv2_connection) | resource |
| [google_cloudbuildv2_repository.github](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloudbuildv2_repository) | resource |
| [google_storage_bucket.log_bucket](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket) | resource |
| [google_storage_bucket.solutions_bucket](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket) | resource |
| [google_storage_bucket_iam_binding.log_bucket](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_iam_binding) | resource |
| [google_storage_bucket_iam_binding.solutions_bucket](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_iam_binding) | resource |
| [google_storage_bucket_iam_member.solutions_bucket_roles](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_iam_member) | resource |
| [google_secret_manager_secret.gh_infra_token](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/secret_manager_secret) | data source |
| [google_secret_manager_secret_version.gh_infra_token](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/secret_manager_secret_version) | data source |
| [google_service_account.project_sa](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/service_account) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bucket_name_prefix"></a> [bucket\_name\_prefix](#input\_bucket\_name\_prefix) | Prefix of the bucket name | `string` | `"bkt"` | no |
| <a name="input_bucket_roles"></a> [bucket\_roles](#input\_bucket\_roles) | Prefix of the bucket name | `map(any)` | `{}` | no |
| <a name="input_common_secrets_project_id"></a> [common\_secrets\_project\_id](#input\_common\_secrets\_project\_id) | Common Secrets project ID. | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | The environment. | `string` | n/a | yes |
| <a name="input_gh_app_installation_id"></a> [gh\_app\_installation\_id](#input\_gh\_app\_installation\_id) | GitHub Application installation ID. | `string` | n/a | yes |
| <a name="input_gh_token_secret"></a> [gh\_token\_secret](#input\_gh\_token\_secret) | GitHub Token secret name. | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Service Catalog project ID. | `string` | n/a | yes |
| <a name="input_project_service_account_email"></a> [project\_service\_account\_email](#input\_project\_service\_account\_email) | Project service account email. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | The region. | `string` | n/a | yes |
| <a name="input_service_catalog_kms_keys"></a> [service\_catalog\_kms\_keys](#input\_service\_catalog\_kms\_keys) | Service Catalog KMS Keys. | `map(any)` | n/a | yes |
| <a name="input_solutions_repository"></a> [solutions\_repository](#input\_solutions\_repository) | GitHub repository object for the Service Catalog solution. | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_github_connection"></a> [github\_connection](#output\_github\_connection) | n/a |
| <a name="output_google_cloudbuildv2_repository"></a> [google\_cloudbuildv2\_repository](#output\_google\_cloudbuildv2\_repository) | n/a |
| <a name="output_log_bucket"></a> [log\_bucket](#output\_log\_bucket) | n/a |
| <a name="output_solutions_bucket"></a> [solutions\_bucket](#output\_solutions\_bucket) | n/a |
| <a name="output_solutions_cloudbuild_trigger"></a> [solutions\_cloudbuild\_trigger](#output\_solutions\_cloudbuild\_trigger) | n/a |
<!-- END_TF_DOCS -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| bucket\_name\_prefix | Prefix of the bucket name | `string` | `"bkt"` | no |
| bucket\_roles | Prefix of the bucket name | `map(any)` | `{}` | no |
| common\_secrets\_project\_id | Common Secrets project ID. | `string` | n/a | yes |
| gh\_app\_installation\_id | GitHub Application installation ID. | `string` | n/a | yes |
| gh\_token\_secret | GitHub Token secret name. | `string` | n/a | yes |
| project\_id | Service Catalog project ID. | `string` | n/a | yes |
| project\_service\_account\_email | Project service account email. | `string` | n/a | yes |
| region | The region. | `string` | n/a | yes |
| service\_catalog\_kms\_keys | Service Catalog KMS Keys. | `map(any)` | n/a | yes |
| solutions\_repository | GitHub repository object for the Service Catalog solution. | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| github\_connection | n/a |
| google\_cloudbuildv2\_repository | n/a |
| log\_bucket | n/a |
| solutions\_bucket | n/a |
| solutions\_cloudbuild\_trigger | n/a |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->