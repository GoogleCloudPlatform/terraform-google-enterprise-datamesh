#!/bin/bash
# Copyright 2024 Google LLC
# shellcheck disable=SC2154

echo "*************** TERRAFORM INIT *******************"
terraform init

echo "*************** TERRAFORM PLAN *******************"
terraform plan

echo "*************** TERRAFORM APPLY ******************"
terraform apply -auto-approve

echo "*************** BUILDING OUTPUT ******************"
outputs=$(terraform output -json)

for key in $(echo "$outputs" | jq -r 'keys[]'); do
    value=$(echo "$outputs" | jq -r --arg key "$key" '.[$key].value')
    export "$key"="$value"
done

printf "\nCommon Service Perimeter: \n\t%s\n" "$common_service_perimeter"
printf "Access Context Manager Policy ID: \n\t%s\n" "$access_context_manager_policy_id"
printf "Development Service Perimeter: \n\t%s\n" "$development_service_perimeter"
printf "Non Production Service Perimeter: \n\t%s\n" "$nonprod_service_perimeter"
printf "Production Service Perimeter: \n\t%s\n" "$production_service_perimeter"
printf "Common Shared Restricted Network Project Number: \n\t%s\n" "$common_shared_restricted_project_number"
printf "Development Shared Restricted Network Project Number: \n\t%s\n" "$development_shared_restricted_project_number"
printf "Non Production Shared Restricted Network Project Number: \n\t%s\n" "$nonprod_shared_restricted_project_number"
printf "Production Shared Restricted Network Project Number: \n\t%s\n" "$production_shared_restricted_project_number"
printf "Common KMS Project Number: \n\t%s\n" "$common_kms_project_number"
printf "Development KMS Project Number: \n\t%s\n" "$development_kms_project_number"
printf "Non Production KMS Project Number: \n\t%s\n" "$nonprod_kms_project_number"
printf "Production KMS Project Number: \n\t%s\n" "$production_kms_project_number"
printf "Common Secrets Project Number: \n\t%s\n" "$common_secrets_project_number"
printf "Common Audit Logs Project Number: \n\t%s\n" "$common_audit_logs_project_number"
printf "Data Governance Project Number: \n\t%s\n" "$data_governance_project_number"
printf "Data Governance Project ID: \n\t%s\n" "$data_governance_project_id"
printf "Artifacts Project Number: \n\t%s\n" "$artifacts_project_number"
printf "Data Domain 1 Non Conf Project Number (Development): \n\t%s\n" "$dev_data_domain_1_non_conf"
printf "Data Domain 1 Non Conf Project ID (Development): \n\t%s\n" "$dev_data_domain_1_non_conf_id"
printf "Data Domain 1 Confidential Project Number (Development): \n\t%s\n" "$dev_data_domain_1_conf"
printf "Data Domain 1 Confidential Project ID (Development): \n\t%s\n" "$dev_data_domain_1_conf_id"
printf "Data Domain 1 Non Conf Project Number (Nonproduction): \n\t%s\n" "$nonprod_data_domain_1_non_conf"
printf "Data Domain 1 Confidential Project Number (Nonproduction): \n\t%s\n" "$nonprod_data_domain_1_conf"
printf "Data Domain 1 Confidential Project ID (Nonproduction): \n\t%s\n" "$nonprod_data_domain_1_conf_id"
printf "Data Domain 1 Non Conf Project Number (Production): \n\t%s\n" "$prod_data_domain_1_non_conf"
printf "Data Domain 1 Confidential Project Number (Production): \n\t%s\n" "$prod_data_domain_1_conf"
printf "Data Domain 1 Confidential Project ID (Production): \n\t%s\n" "$prod_data_domain_1_conf_id"
printf "Data Domain 1 Terraform Non Conf Service Account: \n\t%s\n" "$tf_sa_data_domain_1_non_conf_sa"
printf "Data Domain 1 Terraform Confidential Service Account: \n\t%s\n" "$tf_sa_data_domain_1_conf_sa"
printf "Data Domain 1 Terraform Ingestion Service Account: \n\t%s\n" "$tf_sa_data_domain_1_ingest_sa"
printf "Data Terraform Data Governance Account: \n\t%s\n" "$tf_sa_data_governance_sa"
printf "Data Domain 1 Ingestion Project Number (Development):\n\t%s\n" "$dev_data_domain_1_ingest"
printf "Data Domain 1 Ingestion Project ID (Development):\n\t%s\n" "$dev_data_domain_1_ingest_id"
printf "Data Domain 1 Ingestion Project Number (Nonproduction):\n\t%s\n" "$nonprod_data_domain_1_ingest"
printf "Data Domain 1 Ingestion Project ID (Nonproduction):\n\t%s\n" "$nonprod_data_domain_1_ingest_id"
printf "Data Domain 1 Ingestion Project Number (Production):\n\t%s\n" "$prod_data_domain_1_ingest"
printf "Data Domain 1 Ingestion Project ID (Production):\n\t%s\n" "$prod_data_domain_1_ingest_id"
printf "Service Catalog Project Number: \n\t%s\n" "$service_catalog_project_number"
printf "Service Catalog Terraform Service Account: \n\t%s\n" "$tf_sa_service_catalog"
printf "Consumer 1 Project Number (Development): \n\t%s\n" "$dev_consumer_1"
printf "Consumer 1 Project Number (Nonproduction): \n\t%s\n" "$nonprod_consumer_1"
printf "Consumer 1 Project Number (Production): \n\t%s\n" "$prod_consumer_1"
printf "Non Confidential Data Viewer Group: \n\t%s\n" "$data_viewer_group"
printf "Encrypted Data Viewer Group: \n\t%s\n" "$encrypted_data_viewer_group"
printf "Fine Grained Viewer Group: \n\t%s\n" "$fine_grained_viewer_group"
printf "Masked Data Viewer Group: \n\t%s\n" "$masked_data_viewer_group"
printf "Confidential Data Viewer Group: \n\t%s\n" "$conf_data_viewer_group"

# Pause for user confirmation
read -r -p $'Review the output above.\nIf the output looks correct, press Enter to continue with the rest of the script or Ctrl+C to exit.'

# Update VPCs

echo "Updating environments/shared.auto.tfvars...."

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


echo "Updating environments/development.auto.tfvars...."

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

echo "Updating environments/nonproduction.auto.tfvars...."

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

echo "Updating environments/production.auto.tfvars...."

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

printf "Building perimimeter members for ingress rules....\n"

accounts=(
    "$tf_sa_data_domain_1_ingest_sa"
    "$tf_sa_data_governance_sa"
    "$tf_sa_data_domain_1_conf_sa"
    "$tf_sa_data_domain_1_non_conf_sa"
    "$tf_sa_service_catalog"
    "sa-dataflow-controller@${dev_data_domain_1_ingest_id}.iam.gserviceaccount.com"
    "sa-dataflow-controller@${nonprod_data_domain_1_ingest_id}.iam.gserviceaccount.com"
    "sa-dataflow-controller@${prod_data_domain_1_ingest_id}.iam.gserviceaccount.com"
    "sa-dataflow-controller-reid@${dev_data_domain_1_conf_id}.iam.gserviceaccount.com"
    "sa-dataflow-controller-reid@${nonprod_data_domain_1_conf_id}.iam.gserviceaccount.com"
    "sa-dataflow-controller-reid@${prod_data_domain_1_conf_id}.iam.gserviceaccount.com"
    "cloud-run@${data_governance_project_id}.iam.gserviceaccount.com"
    "cloud-function@${data_governance_project_id}.iam.gserviceaccount.com"
    "service-${data_governance_project_number}@dlp-api.iam.gserviceaccount.com"
    "service-${data_governance_project_number}@gcf-admin-robot.iam.gserviceaccount.com"
    "project-service-account@${dev_data_domain_1_ingest_id}.iam.gserviceaccount.com"
    "sa-pubsub-writer@${dev_data_domain_1_ingest_id}.iam.gserviceaccount.com"
    "tag-creator@${data_governance_project_id}.iam.gserviceaccount.com"
    "tag-engine@${data_governance_project_id}.iam.gserviceaccount.com"
    "cloud-account-pricing@cloud-account-pricing.iam.gserviceaccount.com"
    "record-manager@${data_governance_project_id}.iam.gserviceaccount.com"
    "report-engine@${data_governance_project_id}.iam.gserviceaccount.com"
    "project-service-account@${dev_data_domain_1_non_conf_id}.iam.gserviceaccount.com"
    "${dev_data_domain_1_non_conf}-compute@developer.gserviceaccount.com"
)


printf "Add the following accounts to the ingress rules in common.auto.tfvars in gcp-networks:\n"
for account in "${accounts[@]}"; do
    echo "\"serviceAccount:$account"\",
done