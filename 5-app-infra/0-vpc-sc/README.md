# 5-app-infra

These instructions are part of expanding and deploying the Data Mesh architecture.  Please follow each part in sequence.

<table>
<tbody>
<tr>
<td><a href="../0-vpc-sc">0-vpc-sc</a></td>
<td>Runs a local terraform plan that outputs the necessary configurations for your Service Perimeter.</td>
</tr>
<tr>
<td><a href="../1-tag-engine-oauth">1-tag-engine-oauth</a></td>
<td>Instructions on how to configure OAUTH needed for Data Mesh's Tag Engine.</td>
</tr>
<tr>
<td><a href="../2-artifacts-project">2-artifacts-project</a></td>
<td>Sets up a repository structure and instructions on deploying the artifacts project</td>
</tr>
<tr>
<td><a href="../3-artifact-publish">3-artifact-publish</a></td>
<td>A repository structure containing Dockerfiles and python packages that will be used for building and publishing artifacts</td>
</tr>
<tr>
<td><a href="../4-data-governance">4-data-governance</a></td>
<td>A repository structure containing instructions on deploying the data governance project</td>
</tr>
<tr>
<td><a href="../5-service-catalog-project">5-service-catalog-project</a></td>
<td>A repository structure containing instructions on deploying the service catalog project</td>
</tr>
<tr>
<td><a href="../6-service-catalog-solutions">6-service-catalog-solutions</a></td>
<td>Instructions on how to configure Service Catalog</td>
</tr>
<tr>
<td><a href="../7-data-domain-1-nonconfidential">7-data-domain-1-nonconfidential</a></td>
<td>A repository structure containing instructions on deploying the non-confidential data project</td>
</tr>
<tr>
<td><a href="../8-data-domain-1-ingest">8-data-domain-1-ingest</a></td>
<td>A repository structure containing instructions on deploying the ingest project</td>
</tr>
<tr>
<td><a href="../9-data-domain-1-confidential">9-data-domain-1-confidential</a></td>
<td>A repository structure containing instructions on deploying the confidential data project</td>
</tr>
<tr>
<td><a href="../10-run-cdmc-engines">10-run-cdmc-engines</a></td>
<td>Instructions on how to run the CDMC engines</td>
</tr>
<tr>
<td><a href="../11-consumer-1">11-consumer-1</a></td>
<td>A repository structure containing instructions on deploying the Consumer project</td>
</tr>
<tr>
<td><a href="../12-adding-additional-data">12-adding-additional-data</a></td>
<td>Instructions on how to add additional data domains and/or datasets to an existing data domain</td>
</tr>
</tbody>
</table>

<!-- For an overview of the architecture and the parts, see the
[placeholder](https://github.com/placeholder)
file. -->

## VPC-SC

# Software Requirements
- [jq](https://stedolan.github.io/jq/) version 1.6 or later
- [Bash](https://www.gnu.org/software/bash/) version 5.2 or later
- [Terraform](https://www.terraform.io/downloads.html) version 1.5.7 or later.

Before project expansion begins, it is imperative that the Service Perimeters created in `3-networks-dual-svpc` have the correct ingress and egress policies set.

1. Previously in step `3 networks-dual-svpc` in the [README](../../README.md) we created a temporary egress policy in `common.auto.tfvars` within `gcp-networks`.  Before continuing onto the proceeding steps, this temporary egress policy must be removed.

   This egress policy was necessary for the `terraform apply` commands to succeed in step `4 Projects` without encountering VPC-SC Service Perimeter errors.

   In `gcp-networks`, completely remove the `egress_policy` from `common.auto.tfvars` located at the root of the folder and save the file.

1. CD into this directory
   ```bash
   cd gcp-data-mesh-foundations/5-app-infra/0-vpc-sc
   ```

1. Update `remote_state_bucket` in the `common.auto.tfvars` located within this folder.
   ```bash
   export remote_state_bucket=$(terraform -chdir="../../../gcp-bootstrap/envs/shared" output -raw projects_gcs_bucket_tfstate)
   sed -i'' -e "s/REMOTE_STATE_BUCKET/${remote_state_bucket}/" common.auto.tfvars
   ```


1. Run `update_vpcs.sh`
   ```bash
   bash update_vpcs.sh
   ```

1. If you have run step 4, you can skip steps 6-12.

1. (Optional) Or run the following in your terminal.
   ```bash
   terraform init
   terraform plan
   terraform apply -auto-approve

   outputs=$(terraform output -json)

   for key in $(echo $outputs | jq -r 'keys[]'); do
        value=$(echo $outputs | jq -r --arg key "$key" '.[$key].value')
        export $key="$value"
   done

   printf "Common Service Perimeter: \n\t$common_service_perimeter\n"
   printf "Access Context Manager Policy ID: \n\t$access_context_manager_policy_id\n"
   printf "Development Service Perimeter: \n\t$development_service_perimeter\n"
   printf "Non Production Service Perimeter: \n\t$nonprod_service_perimeter\n"
   printf "Production Service Perimeter: \n\t$production_service_perimeter\n"
   printf "Common Shared Restricted Network Project Number: \n\t$common_shared_restricted_project_number\n"
   printf "Development Shared Restricted Network Project Number: \n\t$development_shared_restricted_project_number\n"
   printf "Non Production Shared Restricted Network Project Number: \n\t$nonprod_shared_restricted_project_number\n"
   printf "Production Shared Restricted Network Project Number: \n\t$production_shared_restricted_project_number\n"
   printf "Common KMS Project Number: \n\t$common_kms_project_number\n"
   printf "Development KMS Project Number: \n\t$development_kms_project_number\n"
   printf "Non Production KMS Project Number: \n\t$nonprod_kms_project_number\n"
   printf "Production KMS Project Number: \n\t$production_kms_project_number\n"
   printf "Common Secrets Project Number: \n\t$common_secrets_project_number\n"
   printf "Common Audit Logs Project Number: \n\t$common_audit_logs_project_number\n"
   printf "Data Governance Project Number: \n\t$data_governance_project_number\n"
   printf "Data Governance Project ID: \n\t$data_governance_project_id\n"
   printf "Artifacts Project Number: \n\t$artifacts_project_number\n"
   printf "Data Domain 1 Non Conf Project Number (Development): \n\t$dev_data_domain_1_non_conf\n"
   printf "Data Domain 1 Non Conf Project ID (Development): \n\t$dev_data_domain_1_conf_id\n"
   printf "Data Domain 1 Confidential Project Number (Development): \n\t$dev_data_domain_1_conf\n"
   printf "Data Domain 1 Confidential Project ID (Development): \n\t$dev_data_domain_1_conf_id\n"
   printf "Data Domain 1 Non Conf Project Number (Nonproduction): \n\t$nonprod_data_domain_1_non_conf\n"
   printf "Data Domain 1 Confidential Project Number (Nonproduction): \n\t$nonprod_data_domain_1_conf\n"
   printf "Data Domain 1 Confidential Project ID (Nonproduction): \n\t$nonprod_data_domain_1_conf_id\n"
   printf "Data Domain 1 Non Conf Project Number (Production): \n\t$prod_data_domain_1_non_conf\n"
   printf "Data Domain 1 Confidential Project Number (Production): \n\t$prod_data_domain_1_conf\n"
   printf "Data Domain 1 Confidential Project ID (Production): \n\t$prod_data_domain_1_conf_id\n"
   printf "Data Domain 1 Terraform Non Conf Service Account: \n\t$tf_sa_data_domain_1_non_conf_sa\n"
   printf "Data Domain 1 Terraform Confidential Service Account: \n\t$tf_sa_data_domain_1_conf_sa\n"
   printf "Data Domain 1 Terraform Ingestion Service Account: \n\t$tf_sa_data_domain_1_ingest_sa\n"
   printf "Data Terraform Data Governance Account: \n\t$tf_sa_data_governance_sa\n"
   printf "Data Domain 1 Ingestion Project Number (Development):\n\t$dev_data_domain_1_ingest\n"
   printf "Data Domain 1 Ingestion Project ID (Development):\n\t$dev_data_domain_1_ingest_id\n"
   printf "Data Domain 1 Ingestion Project Number (Nonproduction):\n\t$nonprod_data_domain_1_ingest\n"
   printf "Data Domain 1 Ingestion Project ID (Nonproduction):\n\t$nonprod_data_domain_1_ingest_id\n"
   printf "Data Domain 1 Ingestion Project Number (Production):\n\t$prod_data_domain_1_ingest\n"
   printf "Data Domain 1 Ingestion Project ID (Production):\n\t$prod_data_domain_1_ingest_id\n"
   printf "Service Catalog Project Number: \n\t$service_catalog_project_number\n"
   printf "Service Catalog Terraform Service Account: \n\t$tf_sa_service_catalog\n"
   printf "Consumer 1 Project Number (Development): \n\t$dev_consumer_1\n"
   printf "Consumer 1 Project Number (Nonproduction): \n\t$nonprod_consumer_1\n"
   printf "Consumer 1 Project Number (Production): \n\t$prod_consumer\n"
   printf "Non Confidential Data Viewer Group: \n\t$data_viewer_group\n"
   printf "Encrypted Data Viewer Group: \n\t$encrypted_data_viewer_group\n"
   printf "Fine Grained Viewer Group: \n\t$fine_grained_viewer_group\n"
   printf "Masked Data Viewer Group: \n\t$masked_data_viewer_group\n"
   printf "Confidential Data Viewer Group: \n\t$conf_data_viewer_group\n"
   ```

1. (Optional) Below, you can find the values that will need to be applied to `common.auto.tfvars` and your `development.auto.tfvars`, `non-production.auto.tfvars` & `production.auto.tfvars`. 

1. (Optional) Create an updated `shared.auto.tfvars` file:
   ```bash
   sed -i'' -e "s/ACCESS_CONTEXT_MANAGER_POLICY_ID/$access_context_manager_policy_id/g" environments/shared.auto.tfvars
   sed -i'' -e "s/COMMON_SERVICE_PERIMETER_NAME/$common_service_perimeter/g" environments/shared.auto.tfvars
   sed -i'' -e "s/COMMON_SHARED_RESTRICTED_PROJECT_NUMBER/$common_shared_restricted_project_number/g" environments/shared.auto.tfvars
   sed -i'' -e "s/DATA_GOVERNANCE_PROJECT_NUMBER/$data_governance_project_number/g" environments/shared.auto.tfvars
   sed -i'' -e "s/COMMON_KMS_PROJECT_NUMBER/$common_kms_project_number/g" environments/shared.auto.tfvars
   sed -i'' -e "s/COMMON_SECRETS_PROJECT_NUMBER/$common_secrets_project_number/g" environments/shared.auto.tfvars
   sed -i'' -e "s/ARTIFACTS_PROJECT_NUMBER/$artifacts_project_number/g" environments/shared.auto.tfvars
   sed -i'' -e "s/DATA_DOMAIN_TF_NON_CONF_SA/$tf_sa_data_domain_1_non_conf_sa/g" environments/shared.auto.tfvars
   sed -i'' -e "s/DATA_DOMAIN_TF_CONF_SA/$tf_sa_data_domain_1_conf_sa/g" environments/shared.auto.tfvars
   sed -i'' -e "s/DEV_DATA_DOMAIN_CONF_PROJECT_ID/$dev_data_domain_1_conf_id/g" environments/shared.auto.tfvars
   sed -i'' -e "s/NONPROD_DATA_DOMAIN_CONF_PROJECT_ID/$nonprod_data_domain_1_conf_id/g" environments/shared.auto.tfvars
   sed -i'' -e "s/PROD_DATA_DOMAIN_CONF_PROJECT_ID/$prod_data_domain_1_conf_id/g" environments/shared.auto.tfvars
   sed -i'' -e "s/DATA_GOVERNANCE_PROJECT_ID/$data_governance_project_id/g" environments/shared.auto.tfvars
   sed -i'' -e "s/DEV_DATA_DOMAIN_NON_CONF_PROJECT_NUMBER/$dev_data_domain_1_non_conf/g" environments/shared.auto.tfvars
   sed -i'' -e "s/DEV_DATA_DOMAIN_NON_CONF_PROJECT_ID/$dev_data_domain_1_non_conf_id/g" environments/shared.auto.tfvars
   sed -i'' -e "s/DEV_DATA_DOMAIN_CONF_PROJECT_NUMBER/$dev_data_domain_1_conf/g" environments/shared.auto.tfvars
   sed -i'' -e "s/NONPROD_DATA_DOMAIN_NON_CONF_PROJECT_NUMBER/$nonprod_data_domain_1_non_conf/g" environments/shared.auto.tfvars
   sed -i'' -e "s/NONPROD_DATA_DOMAIN_CONF_PROJECT_NUMBER/$nonprod_data_domain_1_conf/g" environments/shared.auto.tfvars
   sed -i'' -e "s/PROD_DATA_DOMAIN_NON_CONF_PROJECT_NUMBER/$prod_data_domain_1_non_conf/g" environments/shared.auto.tfvars
   sed -i'' -e "s/PROD_DATA_DOMAIN_CONF_PROJECT_NUMBER/$prod_data_domain_1_conf/g" environments/shared.auto.tfvars
   sed -i'' -e "s/SERVICE_CATALOG_PROJECT_NUMBER/$service_catalog_project_number/g" environments/shared.auto.tfvars
   sed -i'' -e "s/MASKED_DATA_VIEWER_EMAIL/$masked_data_viewer_group/g" environments/shared.auto.tfvars
   sed -i'' -e "s/ENCRYPTED_DATA_VIEWER_EMAIL/$encrypted_data_viewer_group/g" environments/shared.auto.tfvars
   sed -i'' -e "s/FINE_GRAINED_DATA_VIEWER_EMAIL/$fine_grained_viewer_group/g" environments/shared.auto.tfvars
   sed -i'' -e "s/NON_CONF_DATA_VIEWER_EMAIL/$data_viewer_group/g" environments/shared.auto.tfvars
   sed -i'' -e "s/CONF_DATA_VIEWER_EMAIL/$conf_data_viewer_group/g" environments/shared.auto.tfvars
   sed -i'' -e "s/DEV_CONSUMER_PROJECT_NUMBER/$dev_consumer_1/g" environments/shared.auto.tfvars
   sed -i'' -e "s/NONPROD_CONSUMER_PROJECT_NUMBER/$nonprod_consumer_1/g" environments/shared.auto.tfvars
   sed -i'' -e "s/PROD_CONSUMER_PROJECT_NUMBER/$prod_consumer_1/g" environments/shared.auto.tfvars
   ```

1. (Optional) Create an updated `development.auto.tfvars`
   ```bash
      sed -i'' -e "s/ACCESS_CONTEXT_MANAGER_POLICY_ID/$access_context_manager_policy_id/g" environments/development.auto.tfvars
      sed -i'' -e "s/DEVELOPMENT_SERVICE_PERIMETER_NAME/$development_service_perimeter/g" environments/development.auto.tfvars
      sed -i'' -e "s/DEV_SHARED_RESTRICTED_PROJECT_NUMBER/$development_shared_restricted_project_number/g" environments/development.auto.tfvars
      sed -i'' -e "s/DEV_DATA_DOMAIN_CONF_PROJECT_NUMBER/$dev_data_domain_1_conf/g" environments/development.auto.tfvars
      sed -i'' -e "s/DEV_DATA_DOMAIN_NON_CONF_PROJECT_NUMBER/$dev_data_domain_1_non_conf/g" environments/development.auto.tfvars
      sed -i'' -e "s/DEV_DATA_DOMAIN_NON_CONF_PROJECT_ID/$dev_data_domain_1_non_conf_id/g" environments/development.auto.tfvars
      sed -i'' -e "s/DEV_DATA_DOMAIN_INGEST_PROJECT_NUMBER/$dev_data_domain_1_ingest/g" environments/development.auto.tfvars
      sed -i'' -e "s/DEV_DATA_DOMAIN_INGEST_PROJECT_ID/$dev_data_domain_1_ingest_id/g" environments/development.auto.tfvars
      sed -i'' -e "s/DEV_DOMAIN_CONF_PROJECT_ID/$dev_data_domain_1_conf_id/g" environments/development.auto.tfvars
      sed -i'' -e "s/DATA_DOMAIN_TF_NON_CONF_SA/$tf_sa_data_domain_1_non_conf_sa/g" environments/development.auto.tfvars
      sed -i'' -e "s/DATA_DOMAIN_TF_CONF_SA/$tf_sa_data_domain_1_conf_sa/g" environments/development.auto.tfvars
      sed -i'' -e "s/DATA_DOMAIN_TF_INGESTION_SA/$tf_sa_data_domain_1_ingest_sa/g" environments/development.auto.tfvars
      sed -i'' -e "s/DATA_GOVERNANCE_PROJECT_ID/$data_governance_project_id/g" environments/development.auto.tfvars
      sed -i'' -e "s/DATA_GOVERNANCE_PROJECT_NUMBER/$data_governance_project_number/g" environments/development.auto.tfvars
      sed -i'' -e "s/ARTIFACTS_PROJECT_NUMBER/$artifacts_project_number/g" environments/development.auto.tfvars
      sed -i'' -e "s/COMMON_SECRETS_PROJECT_NUMBER/$common_secrets_project_number/g" environments/development.auto.tfvars
      sed -i'' -e "s/COMMON_AUDIT_LOGS_PROJECT_NUMBER/$common_audit_logs_project_number/g" environments/development.auto.tfvars
      sed -i'' -e "s/COMMON_KMS_PROJECT_NUMBER/$common_kms_project_number/g" environments/development.auto.tfvars
      sed -i'' -e "s/DEV_KMS_PROJECT_NUMBER/$development_kms_project_number/g" environments/development.auto.tfvars
      sed -i'' -e "s/NON_CONF_DATA_VIEWER_EMAIL/$data_viewer_group/g" environments/development.auto.tfvars
      sed -i'' -e "s/CONF_DATA_VIEWER_EMAIL/$conf_data_viewer_group/g" environments/development.auto.tfvars
      sed -i'' -e "s/MASKED_DATA_VIEWER_EMAIL/$masked_data_viewer_group/g" environments/development.auto.tfvars
      sed -i'' -e "s/ENCRYPTED_DATA_VIEWER_EMAIL/$encrypted_data_viewer_group/g" environments/development.auto.tfvars
      sed -i'' -e "s/FINE_GRAINED_DATA_VIEWER_EMAIL/$fine_grained_viewer_group/g" environments/development.auto.tfvars
      sed -i'' -e "s/DEV_CONSUMER_PROJECT_NUMBER/$dev_consumer_1/g" environments/development.auto.tfvars
      ```
1. (Optional) Create an update `nonproduction.auto.tfvars`
      ```bash
      sed -i'' -e "s/ACCESS_CONTEXT_MANAGER_POLICY_ID/$access_context_manager_policy_id/g" environments/nonproduction.auto.tfvars
      sed -i'' -e "s/NONPROD_SERVICE_PERIMETER_NAME/$nonprod_service_perimeter/g" environments/nonproduction.auto.tfvars
      sed -i'' -e "s/NONPROD_SHARED_RESTRICTED_PROJECT_NUMBER/$nonprod_shared_restricted_project_number/g" environments/nonproduction.auto.tfvars
      sed -i'' -e "s/NONPROD_DATA_DOMAIN_CONF_PROJECT_NUMBER/$nonprod_data_domain_1_conf/g" environments/nonproduction.auto.tfvars
      sed -i'' -e "s/NONPROD_DATA_DOMAIN_NON_CONF_PROJECT_NUMBER/$nonprod_data_domain_1_non_conf/g" environments/nonproduction.auto.tfvars
      sed -i'' -e "s/NONPROD_DATA_DOMAIN_INGEST_PROJECT_NUMBER/$nonprod_data_domain_1_ingest/g" environments/nonproduction.auto.tfvars
      sed -i'' -e "s/NONPROD_DATA_DOMAIN_INGEST_PROJECT_ID/$nonprod_data_domain_1_ingest_id/g" environments/nonproduction.auto.tfvars
      sed -i'' -e "s/NONPROD_DOMAIN_CONF_PROJECT_ID/$nonprod_data_domain_1_conf_id/g" environments/nonproduction.auto.tfvars
      sed -i'' -e "s/DATA_DOMAIN_TF_NON_CONF_SA/$tf_sa_data_domain_1_non_conf_sa/g" environments/nonproduction.auto.tfvars
      sed -i'' -e "s/DATA_DOMAIN_TF_CONF_SA/$tf_sa_data_domain_1_conf_sa/g" environments/nonproduction.auto.tfvars
      sed -i'' -e "s/DATA_DOMAIN_TF_INGESTION_SA/$tf_sa_data_domain_1_ingest_sa/g" environments/nonproduction.auto.tfvars
      sed -i'' -e "s/DATA_GOVERNANCE_PROJECT_ID/$data_governance_project_id/g" environments/nonproduction.auto.tfvars
      sed -i'' -e "s/DATA_GOVERNANCE_PROJECT_NUMBER/$data_governance_project_number/g" environments/nonproduction.auto.tfvars
      sed -i'' -e "s/ARTIFACTS_PROJECT_NUMBER/$artifacts_project_number/g" environments/nonproduction.auto.tfvars
      sed -i'' -e "s/COMMON_SECRETS_PROJECT_NUMBER/$common_secrets_project_number/g" environments/nonproduction.auto.tfvars
      sed -i'' -e "s/COMMON_AUDIT_LOGS_PROJECT_NUMBER/$common_audit_logs_project_number/g" environments/nonproduction.auto.tfvars
      sed -i'' -e "s/COMMON_KMS_PROJECT_NUMBER/$common_kms_project_number/g" environments/nonproduction.auto.tfvars
      sed -i'' -e "s/NONPROD_KMS_PROJECT_NUMBER/$nonprod_kms_project_number/g" environments/nonproduction.auto.tfvars
      sed -i'' -e "s/NON_CONF_DATA_VIEWER_EMAIL/$data_viewer_group/g" environments/nonproduction.auto.tfvars
      sed -i'' -e "s/CONF_DATA_VIEWER_EMAIL/$conf_data_viewer_group/g" environments/nonproduction.auto.tfvars
      sed -i'' -e "s/MASKED_DATA_VIEWER_EMAIL/$masked_data_viewer_group/g" environments/nonproduction.auto.tfvars
      sed -i'' -e "s/ENCRYPTED_DATA_VIEWER_EMAIL/$encrypted_data_viewer_group/g" environments/nonproduction.auto.tfvars
      sed -i'' -e "s/FINE_GRAINED_DATA_VIEWER_EMAIL/$fine_grained_viewer_group/g" environments/nonproduction.auto.tfvars
      sed -i'' -e "s/NONPROD_CONSUMER_PROJECT_NUMBER/$nonprod_consumer_1/g" environments/nonproduction.auto.tfvars
      ```
1. (Optional) Create an updated `production.auto.tfvars`
   ```bash
   sed -i'' -e "s/ACCESS_CONTEXT_MANAGER_POLICY_ID/$access_context_manager_policy_id/g" environments/production.auto.tfvars
   sed -i'' -e "s/PRODUCTION_SHARED_RESTRICTED_PROJECT_NUMBER/$production_shared_restricted_project_number/g" environments/production.auto.tfvars
   sed -i'' -e "s/PRODUCTION_SERVICE_PERIMETER_NAME/$production_service_perimeter/g" environments/production.auto.tfvars
   sed -i'' -e "s/PRODUCTION_DATA_DOMAIN_CONF_PROJECT_NUMBER/$prod_data_domain_1_conf/g" environments/production.auto.tfvars
   sed -i'' -e "s/PRODUCTION_DATA_DOMAIN_NON_CONF_PROJECT_NUMBER/$prod_data_domain_1_non_conf/g" environments/production.auto.tfvars
   sed -i'' -e "s/PRODUCTION_DATA_DOMAIN_INGEST_PROJECT_NUMBER/$prod_data_domain_1_ingest/g" environments/production.auto.tfvars
   sed -i'' -e "s/PRODUCTION_DATA_DOMAIN_INGEST_PROJECT_ID/$prod_data_domain_1_ingest_id/g" environments/production.auto.tfvars
   sed -i'' -e "s/PRODUCTION_DOMAIN_CONF_PROJECT_ID/$prod_data_domain_1_conf_id/g" environments/production.auto.tfvars
   sed -i'' -e "s/DATA_DOMAIN_TF_NON_CONF_SA/$tf_sa_data_domain_1_non_conf_sa/g" environments/production.auto.tfvars
   sed -i'' -e "s/DATA_DOMAIN_TF_CONF_SA/$tf_sa_data_domain_1_conf_sa/g" environments/production.auto.tfvars
   sed -i'' -e "s/DATA_DOMAIN_TF_INGESTION_SA/$tf_sa_data_domain_1_ingest_sa/g" environments/production.auto.tfvars
   sed -i'' -e "s/DATA_GOVERNANCE_PROJECT_ID/$data_governance_project_id/g" environments/production.auto.tfvars
   sed -i'' -e "s/DATA_GOVERNANCE_PROJECT_NUMBER/$data_governance_project_number/g" environments/production.auto.tfvars
   sed -i'' -e "s/ARTIFACTS_PROJECT_NUMBER/$artifacts_project_number/g" environments/production.auto.tfvars
   sed -i'' -e "s/COMMON_SECRETS_PROJECT_NUMBER/$common_secrets_project_number/g" environments/production.auto.tfvars
   sed -i'' -e "s/COMMON_AUDIT_LOGS_PROJECT_NUMBER/$common_audit_logs_project_number/g" environments/production.auto.tfvars
   sed -i'' -e "s/COMMON_KMS_PROJECT_NUMBER/$common_kms_project_number/g" environments/production.auto.tfvars
   sed -i'' -e "s/PRODUCTION_KMS_PROJECT_NUMBER/$production_kms_project_number/g" environments/production.auto.tfvars
   sed -i'' -e "s/NON_CONF_DATA_VIEWER_EMAIL/$data_viewer_group/g" environments/production.auto.tfvars
   sed -i'' -e "s/CONF_DATA_VIEWER_EMAIL/$conf_data_viewer_group/g" environments/production.auto.tfvars
   sed -i'' -e "s/MASKED_DATA_VIEWER_EMAIL/$masked_data_viewer_group/g" environments/production.auto.tfvars
   sed -i'' -e "s/ENCRYPTED_DATA_VIEWER_EMAIL/$encrypted_data_viewer_group/g" environments/production.auto.tfvars
   sed -i'' -e "s/FINE_GRAINED_DATA_VIEWER_EMAIL/$fine_grained_viewer_group/g" environments/production.auto.tfvars
   sed -i'' -e "s/PROD_CONSUMER_PROJECT_NUMBER/$prod_consumer_1/g" environments/production.auto.tfvars
   ```

1. (Optional) Additional perimeter members must be added for ingress rules.  Run the below code in your terminal:
    ```bash
   accounts=(
      $tf_sa_data_domain_1_ingest_sa
      $tf_sa_data_governance_sa
      $tf_sa_data_domain_1_conf_sa
      $tf_sa_data_domain_1_non_conf_sa
      $tf_sa_service_catalog
      sa-dataflow-controller@${dev_data_domain_1_ingest_id}.iam.gserviceaccount.com
      sa-dataflow-controller@${nonprod_data_domain_1_ingest_id}.iam.gserviceaccount.com
      sa-dataflow-controller@${prod_data_domain_1_ingest_id}.iam.gserviceaccount.com
      sa-dataflow-controller-reid@${dev_data_domain_1_conf_id}.iam.gserviceaccount.com
      sa-dataflow-controller-reid@${nonprod_data_domain_1_conf_id}.iam.gserviceaccount.com
      sa-dataflow-controller-reid@${prod_data_domain_1_conf_id}.iam.gserviceaccount.com
      cloud-run@${data_governance_project_id}.iam.gserviceaccount.com
      cloud-function@${data_governance_project_id}.iam.gserviceaccount.com
      service-${data_governance_project_number}@dlp-api.iam.gserviceaccount.com
      service-${data_governance_project_number}@gcf-admin-robot.iam.gserviceaccount.com
      project-service-account@${dev_data_domain_1_ingest_id}.iam.gserviceaccount.com
      sa-pubsub-writer@${dev_data_domain_1_ingest_id}.iam.gserviceaccount.com
      tag-creator@${data_governance_project_id}.iam.gserviceaccount.com
      tag-engine@${data_governance_project_id}.iam.gserviceaccount.com
      cloud-account-pricing@cloud-account-pricing.iam.gserviceaccount.com
      record-manager@${data_governance_project_id}.iam.gserviceaccount.com
      report-engine@${data_governance_project_id}.iam.gserviceaccount.com
      project-service-account@${$dev_data_domain_1_non_conf_id}.iam.gserviceaccount.com
      ${dev_data_domain_1_non_conf}-compute@developer.gserviceaccount.com
   )

    for account in "${accounts[@]}"; do
        echo "\"serviceAccount:$account"\",
    done
    ```
1. Update the `common.auto.tfvars` in `gcp-networks` under `perimeter_additional_members`.  If you ran the bash script, this will be scripts final output.

1. Review the files `nonproduction.auto.tfvars`, `development.auto.tfvars`, `shared.auto.tfvars` and `production.auto.tfvars` that have been modified _in the `environments` folder_ .  Ensure they have been fully populated.

1. Go to `gcp-networks` and and update `shared.auto.tfvars` with the contents of the file located in the `environments` by the same name in the folder located here.

1. Place `development.auto.tfvars`, `nonproduction.auto.tfvars` and `production.auto.tfvars` into the `environments` folder in `gcp-networks`

   ```bash
   cp environments/development.auto.tfvars ../../../gcp-networks/development.auto.tfvars
   cp environments/nonproduction.auto.tfvars ../../../gcp-networks/nonproduction.auto.tfvars
   cp environments/production.auto.tfvars ../../../gcp-networks/production.auto.tfvars
   ```

1. Create links to `development.auto.tfvars`, `nonproduction.auto.tfvars` and `production.auto.tfvars` in `gcp-networks`.

   ```bash
   ln -s ../../development.auto.tfvars ../../../gcp-networks/envs/development/development.auto.tfvars
   ln -s ../../nonproduction.auto.tfvars ../../../gcp-networks/envs/nonproduction/nonproduction.auto.tfvars
   ln -s ../../production.auto.tfvars ../../../gcp-networks/envs/production/production.auto.tfvars
   ```

1. Change Directory out of this folder
   ```bash
   cd ../..
   ```

1. Push to your repository in `gcp-networks` and create a PR to the Development branch and observe the plan.  Once passed, merge your code to Development.  Repeat your merging all the way to Production to complete the full environment changes.