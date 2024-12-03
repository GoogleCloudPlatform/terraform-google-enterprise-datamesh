## Dataflow service catalog solution

When deployin Dataflow solution, Dataflow service can be connected either to Cloud Stroage or Pub/Sub services for data ingestion.

Below are example configurations for both cases, for the `dataflow_flex_job` and `parameters` variable:

1. For the Cloud Storage ingestion, use the following examples:

* `dataflow_flex_job`:

```bash
{
  image_name            = "us-central1-docker.pkg.dev/prj-c-bu2-artifacts-ks3d/flex-templates/samples/gcs_to_bq_deidentification:latest"
  template_filename     = "gs://bkt-prj-c-bu2-artifacts-ks3d-us-central1-tpl-b58f/flex-template-samples/gcs_to_bq_deidentification.json"
}
```

* `parameters`:

```bash
{
  bq_schema                      = "Card_Type_Code:STRING,Card_Type_Full_Name:STRING,Issuing_Bank:STRING,Card_Number:STRING,Card_Holders_Name:STRING,CVV_CVV2:STRING,Issue_Date:STRING,Expiry_Date:STRING,Billing_Date:STRING,Card_PIN:STRING,Credit_Limit:STRING"
  cryptoKeyName                  = "projects/prj-c-kms-fc4b/locations/us-central1/keyRings/sample-keyring/cryptoKeys/deidenfication_key_common"
  deidentification_template_name = "projects/prj-c-bu2-data-governance-89fk/locations/us-central1/deidentifyTemplates/de_identification_656f665ea9c13b0f"
  dlp_location                   = "us-central1"
  dlp_project                    = "prj-c-bu2-data-governance-89fk"
  gcs_input_file                 = "gs://bkt-domain-1-data-ingestion-development/sample-100-encrypted.csv"
  max_batch_size                 = 1000
  min_batch_size                 = 10
  output_table                   = "prj-d-bu2-domain-1-ncnf-g750:bu2_non_confidential_dataset_development.cc_data_interactive_test"
  sdk_container_image            = "us-central1-docker.pkg.dev/prj-c-bu2-artifacts-ks3d/flex-templates/samples/gcs_to_bq_deidentification:latest"
  temp_location                  = "gs://bkt-d-dataflow/temp/"
  wrappedKey                     = "projects/826586300218/secrets/kms-wrapper/versions/5"
}
```

2. For the Pub/Sub ingestion, use the following examples:

* `dataflow_flex_job`:

```bash
{
  image_name            = "us-central1-docker.pkg.dev/prj-c-bu2-artifacts-ks3d/flex-templates/samples/pubsub_to_bq_deidentification:latest"
  template_filename     = "gs://bkt-prj-c-bu2-artifacts-ks3d-us-central1-tpl-b58f/flex-template-samples/pubsub_to_bq_deidentification.json"
  additional_parameters = {}
}
```

* `parameters`:

```bash
{
  input_topic                    = "projects/prj-d-bu2-domain-1-ngst-ay3k/topics/pubsub-topic"
  window_interval_sec            = 30
  output_table                   = "prj-d-bu2-domain-1-ncnf-g750:bu2_non_confidential_dataset_development.cc_data_interactive_test"
  bq_schema                      = "Card_Type_Code:STRING,Card_Type_Full_Name:STRING,Issuing_Bank:STRING,Card_Number:STRING,Card_Holders_Name:STRING,CVV_CVV2:STRING,Issue_Date:STRING,Expiry_Date:STRING,Billing_Date:STRING,Card_PIN:STRING,Credit_Limit:STRING"
  batch_size                     = 1000
  dlp_project                    = "prj-c-bu2-data-governance-89fk"
  deidentification_template_name = "projects/prj-c-bu2-data-governance-89fk/locations/us-central1/deidentifyTemplates/de_identification_656f665ea9c13b0f"
  dlp_location                   = "us-central1"
  cryptoKeyName                  = "projects/prj-c-kms-fc4b/locations/us-central1/keyRings/sample-keyring/cryptoKeys/deidenfication_key_common"
  wrappedKey                     = "projects/826586300218/secrets/kms-wrapper/versions/5"
  sdk_container_image            = "us-central1-docker.pkg.dev/prj-c-bu2-artifacts-ks3d/flex-templates/samples/pubsub_to_bq_deidentification:latest"
  temp_location                  = "gs://bkt-d-dataflow/temp/"
}
```


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
| <a name="provider_google"></a> [google](#provider\_google) | 5.44.2 |
| <a name="provider_google-beta"></a> [google-beta](#provider\_google-beta) | 5.44.2 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google-beta_google_dataflow_flex_template_job.dataflow_flex_job](https://registry.terraform.io/providers/hashicorp/google-beta/latest/docs/resources/google_dataflow_flex_template_job) | resource |
| [google_compute_subnetwork.subnetwork](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_subnetwork) | data source |
| [google_kms_crypto_key.key](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/kms_crypto_key) | data source |
| [google_kms_key_ring.kms](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/kms_key_ring) | data source |
| [google_project.project](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/project) | data source |
| [google_projects.kms](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/projects) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_experiments"></a> [additional\_experiments](#input\_additional\_experiments) | List of experiments that should be used by the job. | `list(string)` | `[]` | no |
| <a name="input_addtional_parameters"></a> [addtional\_parameters](#input\_addtional\_parameters) | Additional parameters | `map(any)` | `{}` | no |
| <a name="input_autoscaling_algorithm"></a> [autoscaling\_algorithm](#input\_autoscaling\_algorithm) | The algorithm to use for autoscaling. | `string` | `null` | no |
| <a name="input_data_domain"></a> [data\_domain](#input\_data\_domain) | Data Domain name. | `string` | `"domain-1"` | no |
| <a name="input_dataflow_template_jobs"></a> [dataflow\_template\_jobs](#input\_dataflow\_template\_jobs) | Dataflow template job | <pre>object({<br>    image_name            = string<br>    template_filename     = string<br>    additional_parameters = optional(map(string))<br>  })</pre> | <pre>{<br>  "additional_parameters": {},<br>  "image_name": "us-central1-docker.pkg.dev/prj-c-bu2-artifacts-ks3d/flex-templates/samples/gcs_to_bq_deidentification:latest",<br>  "template_filename": "gs://bkt-prj-c-bu2-artifacts-ks3d-us-central1-tpl-b58f/flex-template-samples/gcs_to_bq_deidentification.json"<br>}</pre> | no |
| <a name="input_enable_streaming_engine"></a> [enable\_streaming\_engine](#input\_enable\_streaming\_engine) | Immutable. Indicates if the job should use the streaming engine feature. | `bool` | `false` | no |
| <a name="input_ip_configuration"></a> [ip\_configuration](#input\_ip\_configuration) | The configuration for VM IPs. | `string` | `"WORKER_IP_PRIVATE"` | no |
| <a name="input_job_name"></a> [job\_name](#input\_job\_name) | Name of the flex job. | `string` | n/a | yes |
| <a name="input_keyring_name"></a> [keyring\_name](#input\_keyring\_name) | Central keyring name | `string` | `"sample-keyring"` | no |
| <a name="input_labels"></a> [labels](#input\_labels) | Labels to be attached to the buckets | `map(string)` | <pre>{<br>  "classification": "dataclassification",<br>  "label": "samplelabel",<br>  "owner": "testowner"<br>}</pre> | no |
| <a name="input_launcher_machine_type"></a> [launcher\_machine\_type](#input\_launcher\_machine\_type) | The machine type to use for the Dataflow job launcher. | `string` | `"n1-standard-1"` | no |
| <a name="input_max_workers"></a> [max\_workers](#input\_max\_workers) | Immutable. The maximum number of Google Compute Engine instances to be made available to your pipeline during execution, from 1 to 1000. | `number` | `10` | no |
| <a name="input_num_workers"></a> [num\_workers](#input\_num\_workers) | Immutable. The initial number of Google Compute Engine instances for the job. | `number` | `1` | no |
| <a name="input_parameters"></a> [parameters](#input\_parameters) | Template specific Key/Value pairs to be forwarded to the pipeline's options; keys are case-sensitive based on the language on which the pipeline is coded, mostly Java. Note: do not configure Dataflow options here in parameters. | `map(any)` | `{}` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Optional Project ID. | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | The resource region, one of [us-central1, us-east4]. | `string` | `"us-central1"` | no |
| <a name="input_restricted_host_project_id"></a> [restricted\_host\_project\_id](#input\_restricted\_host\_project\_id) | Shared network project id. | `string` | `"RESTRICTED_HOST_PROJECT_ID"` | no |
| <a name="input_sdk_container_image"></a> [sdk\_container\_image](#input\_sdk\_container\_image) | The container image for the SDK. | `string` | `null` | no |
| <a name="input_staging_location"></a> [staging\_location](#input\_staging\_location) | The Cloud Storage path to use for staging files. Must be a valid Cloud Storage URL, beginning with gs://. | `string` | `null` | no |
| <a name="input_temp_location"></a> [temp\_location](#input\_temp\_location) | The Cloud Storage path to use for temporary files. Must be a valid Cloud Storage URL, beginning with gs://. | `string` | `null` | no |
| <a name="input_transform_name_mapping"></a> [transform\_name\_mapping](#input\_transform\_name\_mapping) | Only applicable when updating a pipeline. Map of transform name prefixes of the job to be replaced with the corresponding name prefixes of the new job.Only applicable when updating a pipeline. Map of transform name prefixes of the job to be replaced with the corresponding name prefixes of the new job. | `map(string)` | `{}` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| additional\_experiments | List of experiments that should be used by the job. | `list(string)` | `[]` | no |
| addtional\_parameters | Additional parameters | `map(any)` | `{}` | no |
| autoscaling\_algorithm | The algorithm to use for autoscaling. | `string` | `null` | no |
| data\_domain | Data Domain name. | `string` | `"domain-1"` | no |
| dataflow\_template\_jobs | Dataflow template job | <pre>object({<br>    image_name            = string<br>    template_filename     = string<br>    additional_parameters = optional(map(string))<br>  })</pre> | <pre>{<br>  "additional_parameters": {},<br>  "image_name": "us-central1-docker.pkg.dev/prj-c-bu2-artifacts-ks3d/flex-templates/samples/gcs_to_bq_deidentification:latest",<br>  "template_filename": "gs://bkt-prj-c-bu2-artifacts-ks3d-us-central1-tpl-b58f/flex-template-samples/gcs_to_bq_deidentification.json"<br>}</pre> | no |
| enable\_streaming\_engine | Immutable. Indicates if the job should use the streaming engine feature. | `bool` | `false` | no |
| ip\_configuration | The configuration for VM IPs. | `string` | `"WORKER_IP_PRIVATE"` | no |
| job\_name | Name of the flex job. | `string` | n/a | yes |
| keyring\_name | Central keyring name | `string` | `"sample-keyring"` | no |
| labels | Labels to be attached to the buckets | `map(string)` | <pre>{<br>  "classification": "dataclassification",<br>  "label": "samplelabel",<br>  "owner": "testowner"<br>}</pre> | no |
| launcher\_machine\_type | The machine type to use for the Dataflow job launcher. | `string` | `"n1-standard-1"` | no |
| max\_workers | Immutable. The maximum number of Google Compute Engine instances to be made available to your pipeline during execution, from 1 to 1000. | `number` | `10` | no |
| num\_workers | Immutable. The initial number of Google Compute Engine instances for the job. | `number` | `1` | no |
| parameters | Template specific Key/Value pairs to be forwarded to the pipeline's options; keys are case-sensitive based on the language on which the pipeline is coded, mostly Java. Note: do not configure Dataflow options here in parameters. | `map(any)` | `{}` | no |
| project\_id | Optional Project ID. | `string` | `null` | no |
| region | The resource region, one of [us-central1, us-east4]. | `string` | `"us-central1"` | no |
| restricted\_host\_project\_id | Shared network project id. | `string` | `"RESTRICTED_HOST_PROJECT_ID"` | no |
| sdk\_container\_image | The container image for the SDK. | `string` | `null` | no |
| staging\_location | The Cloud Storage path to use for staging files. Must be a valid Cloud Storage URL, beginning with gs://. | `string` | `null` | no |
| temp\_location | The Cloud Storage path to use for temporary files. Must be a valid Cloud Storage URL, beginning with gs://. | `string` | `null` | no |
| transform\_name\_mapping | Only applicable when updating a pipeline. Map of transform name prefixes of the job to be replaced with the corresponding name prefixes of the new job.Only applicable when updating a pipeline. Map of transform name prefixes of the job to be replaced with the corresponding name prefixes of the new job. | `map(string)` | `{}` | no |

## Outputs

No outputs.

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->