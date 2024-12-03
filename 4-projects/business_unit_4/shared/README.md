<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| consumer\_groups | n/a | <pre>object({<br>    confidential_data_viewer                  = string<br>    non_confidential_data_viewer              = string<br>    non_confidential_encrypted_data_viewer    = string<br>    non_confidential_fine_grained_data_viewer = string<br>    non_confidential_masked_data_viewer       = string<br>  })</pre> | n/a | yes |
| create\_github\_artifact\_repositories | Create GitHub artifactrepositories | `bool` | `true` | no |
| create\_repositories | create github repositories | `bool` | n/a | yes |
| default\_region | Default region to create resources where applicable. | `string` | `"us-central1"` | no |
| gh\_artifact\_repos | GitHub common Artifact Repo | <pre>object({<br>    owner                  = string<br>    artifact_project_repos = map(string)<br>  })</pre> | `null` | no |
| gh\_common\_project\_repos | GitHub Common Project Repos | <pre>object({<br>    owner         = string<br>    project_repos = map(string)<br>  })</pre> | `null` | no |
| github\_app\_infra\_token | value of github app infra token | `string` | n/a | yes |
| github\_app\_installation\_id | Github App Installation ID | `number` | n/a | yes |
| key\_rotation\_period | Rotation period in seconds to be used for KMS Key | `string` | `"7776000s"` | no |
| project\_budget | Budget configuration.<br>  budget\_amount: The amount to use as the budget.<br>  alert\_spent\_percents: A list of percentages of the budget to alert on when threshold is exceeded.<br>  alert\_pubsub\_topic: The name of the Cloud Pub/Sub topic where budget related messages will be published, in the form of `projects/{project_id}/topics/{topic_id}`.<br>  alert\_spend\_basis: The type of basis used to determine if spend has passed the threshold. Possible choices are `CURRENT_SPEND` or `FORECASTED_SPEND` (default). | <pre>object({<br>    budget_amount        = optional(number, 1000)<br>    alert_spent_percents = optional(list(number), [1.2])<br>    alert_pubsub_topic   = optional(string, null)<br>    alert_spend_basis    = optional(string, "FORECASTED_SPEND")<br>  })</pre> | `{}` | no |
| remote\_state\_bucket | Backend bucket to load Terraform Remote State Data from previous steps. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| app\_infra\_artifacts\_kms\_keys | n/a |
| app\_infra\_artifacts\_project\_id | n/a |
| app\_infra\_artifacts\_project\_number | n/a |
| app\_infra\_cloudbuild\_service\_account\_id | n/a |
| app\_infra\_github\_actions\_project\_id | App Infra Github Actions Project Id |
| apply\_triggers\_id | CB apply triggers |
| artifact\_buckets | GCS Buckets to store Cloud Build Artifacts |
| bq\_keys | Keys for BQ in Data Governance |
| cloudbuild\_project\_id | n/a |
| common\_secrets\_project\_id | Common Secrets Project Id |
| data\_governance\_project\_enabled\_apis | Data Governance Project Enabled APIs |
| data\_governance\_project\_id | Data Governance Project Id |
| data\_governance\_project\_kms\_keys | Keys created for the data governance project |
| data\_governance\_project\_number | Data Governance Project Number |
| data\_governance\_project\_sa | Data Governance Project Name |
| data\_governance\_sa\_cloud\_function | Data Governance Cloud Function Service Account |
| data\_governance\_sa\_cloud\_run | Data Governance Cloud Run Service Account |
| data\_governance\_sa\_data\_access\_management | Data Governance Record Manager Service Account |
| data\_governance\_sa\_record\_manager | Data Governance Record Manager Service Account |
| data\_governance\_sa\_report\_engine | Data Governance Record Manager Service Account |
| data\_governance\_sa\_scheduler\_controller | Data Governance Scheduler Controller Service Account |
| data\_governance\_sa\_tag\_creator | Data Governance Tag Creator Service Account |
| data\_governance\_sa\_tag\_engine | Data Governance Tag Engine Service Account |
| data\_governance\_service\_agent\_cloud\_run | Data Governance Cloud Run Service Agent |
| data\_governance\_tf\_state\_bucket | data governance TF state bucket |
| data\_viewer\_groups\_email | All data viewer groups |
| default\_region | Default region to create resources where applicable. |
| deidentify\_keys | Deidentify keys |
| dlp\_kms\_wrapper\_secret\_name | DLP KMS Wrapper Secret Id |
| enable\_cloudbuild\_deploy | Enable infra deployment using Cloud Build. |
| fs\_keys | Keys for FS in Data Governance |
| github\_app\_installation\_id | n/a |
| github\_repository\_artifact\_repo | n/a |
| kms\_wrapper\_secret\_name | KMS Wrapper Secret Name |
| log\_buckets | GCS Buckets to store Cloud Build logs |
| plan\_triggers\_id | CB plan triggers |
| repos | Cloudbuild Repos to store source code |
| service\_catalog | n/a |
| service\_catalog\_project\_kms\_keys | Keys created for the service catalog project |
| state\_buckets | GCS Buckets to store TF state |
| tag\_engine\_oauth\_client\_id\_secret\_name | Tag Engine OAuth Client Id Secret Id |
| terraform\_service\_accounts | APP Infra Pipeline Terraform Accounts. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
