<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| consumer\_groups | n/a | <pre>object({<br>    confidential_data_viewer                  = string<br>    non_confidential_data_viewer              = string<br>    non_confidential_encrypted_data_viewer    = string<br>    non_confidential_fine_grained_data_viewer = string<br>    non_confidential_masked_data_viewer       = string<br>  })</pre> | n/a | yes |
| create\_resource\_locations\_policy | Whether to create the Organization policy to limit resource location for confidential and non-confidential projects<br>    Required for the Tag engine. However, if the policy is created on the initial Terraform apply, the validation (gcloud terraform vet)<br>    fails with error: Error converting TF resource to CAI: Invalid parent address() for an asset.<br>    So the idea is to skip the policy creation on the initial Terraform apply, then enable it once the projects are created. | `bool` | `true` | no |
| remote\_state\_bucket | Backend bucket to load Terraform Remote State Data from previous steps. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| bigquery\_default\_service\_accounts\_confidential | The bigquery default service accounts. |
| bigquery\_default\_service\_accounts\_non\_confidential | The bigquery default service accounts. |
| consumer\_projects | The consumer projects. |
| consumer\_projects\_kms | The consumer projects kms keys |
| data\_domain\_confidential\_projects | The data domain confidential projects. |
| data\_domain\_confidential\_projects\_kms | The data domain confidential projects. |
| data\_domain\_ingestion\_project\_kms | The data domain projects kms keys |
| data\_domain\_ingestion\_projects | The data domain projects. |
| data\_domain\_non\_confidential\_projects | The data domain non confidential projects. |
| data\_domain\_non\_confidential\_projects\_kms | The data domain non confidential projects. |
| data\_ingestion\_buckets | The data ingestion buckets. |
| data\_mesh\_crypto\_key\_ids | The data mesh crypto keys. |
| dataflow\_controller\_service\_accounts | The dataflow controller service accounts. |
| dataflow\_controller\_service\_accounts\_confidential | The dataflow controller service accounts. |
| pubsub\_writer\_service\_accounts | The pubsub writer service accounts. |
| scheduler\_controller\_service\_accounts | The scheduler controller service accounts. |
| storage\_writer\_service\_accounts | The storage writer service accounts. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
