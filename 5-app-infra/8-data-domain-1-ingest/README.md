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

# Data Domain 1 Ingest
Repository for domain-1-ingest

## Deploying gcp-dm-bu4-prj-domain-1-ingest

1. clone your repository that was created in 4-projects
   ```bash
   git clone git@github.com:[git-owner-name]/gcp-dm-bu4-prj-domain-1-ingest.git bu4-prj-domain-1-ingest
   ```

1. cd over to the `bu4-prj-domain-1-ingest` directory
    ```bash
    cd bu4-prj-domain-1-ingest
    ```
1. Seed the repository if it has not been initialized yet.

   ```bash
   git commit --allow-empty -m 'repository seed'
   git push --set-upstream origin main

   git checkout -b production
   git push --set-upstream origin production

   git checkout -b nonproduction
   git push --set-upstream origin nonproduction

   git checkout -b plan
   ```
1. Copy contents of foundation to new repo.

   ```bash
   cp -RT ../gcp-data-mesh-foundations/policy-library/ ./policy-library
   cp ../gcp-data-mesh-foundations/build/cloudbuild-connection-tf-* .
   cp ../gcp-data-mesh-foundations/build/tf-wrapper.sh .
   chmod 755 ./tf-wrapper.sh
   ```

1. Copy contents over to new repo.
   ```bash
   cp -R ../gcp-data-mesh-foundations/5-app-infra/8-data-domain-1-ingest/* .
   ```

1. Update the `backend.tf` files with the backend bucket from step Projects.
    ```bash
    export backend_bucket=$(terraform -chdir="../gcp-projects/business_unit_4/shared" output  -json state_buckets | jq -r '."domain-1-ingest"')

    for i in `find . -name 'backend.tf'`; do sed -i'' -e "s/UPDATE_APP_INFRA_BUCKET/${backend_bucket}/" $i; done
    ```
1. Update `remote_state_bucket` in common.auto.tfvars
   ```bash
   export remote_state_bucket=$(terraform -chdir="../gcp-bootstrap/envs/shared" output -raw projects_gcs_bucket_tfstate)
   sed -i'' -e "s/REMOTE_STATE_BUCKET/${remote_state_bucket}/" common.auto.tfvars
   ```

1. Update `data_governance_state_bucket` in common.auto.tfvars
   ```bash
   export data_governance_state_bucket=$(terraform -chdir="../gcp-projects/business_unit_4/shared" output -json state_buckets | jq -r '."data-governance"')
   sed -i'' -e "s/DATA_GOVERNANCE_STATE_BUCKET/${data_governance_state_bucket}/" common.auto.tfvars
   ```

1. Update `dataflow_gcs_bucket_url` in common.auto.tfvars. This contains the templates created in `gcp-dm-bu4-prj-artifacts`
   ```bash
   terraform -chdir="../bu4-prj-artifacts/envs/shared" init
   export gcs_bucket_url=$(terraform -chdir="../bu4-prj-artifacts/envs/shared" output -json gcs_template_bucket | jq -r .url)

   sed -i'' -e "s|UPDATE_TEMPLATE_BUCKET_URL|${gcs_bucket_url}|" common.auto.tfvars
   ```

## Ingesting data into GCS - Encrypting and Uploading
Before proceeding on with the data ingestion process, we need to encrypt data from csv files and store it in GCS.

1. The first step is to generate an encrypted version of each plaintext CSV file that you plan to ingest. Once encrypted, these files will be uploaded to GCS, allowing Dataflow to ingest the data and populate the relevant BigQuery tables.

1. Run the following commands to export the necessary environment variables for encryption.  These variables include the KMS crypto key and the wrapped key, which will be used to securely encrypt the files:

   ```bash
   export cryptokeyname=$(terraform -chdir="../gcp-projects/business_unit_4/shared" output -json deidentify_keys | jq -r '."deidenfication_key_common-us-central1"')

   export org_tf_sa=$(terraform -chdir="../gcp-bootstrap/envs/shared" output -raw organization_step_terraform_service_account_email)

   export common_secrets_project_id=$(terraform -chdir="../gcp-projects/business_unit_4/shared" output -raw common_secrets_project_id)
   export secret_name=$(terraform -chdir="../gcp-projects/business_unit_4/shared" output -raw kms_wrapper_secret_name)

   echo "Crypto Key Name: $cryptokeyname"
   echo "Organization Terraform Service Account: $org_tf_sa"
   echo "Common Secrets Project ID: $common_secrets_project_id"
   echo "Secret Name: $secret_name"
   ```

   ```bash
   wrappedkey=$(gcloud secrets versions list $secret_name --project=$common_secrets_project_id --uri | head -n 1 | sed 's|https://secretmanager.googleapis.com/v1/||')

   echo "Wrapped Key: $wrappedkey"
   ```

1. Impersonate the organization terraform service account to create the keyset:

   ```bash
   gcloud auth application-default login --impersonate-service-account=${org_tf_sa}
   ```

1. Create an `encrypted_data` folder at the root of this repository.
   ```bash
   mkdir encrypted_data
   ```
1. Navigate to the directory containing the encryption helper script and execute it for each CSV file you want to encrypt. The script will output encrypted versions of each file.
   ```bash
   cd helpers/csv-enc-emulator
   ```

1. Read the [README.md](helpers/csv-enc-emulator/README.md) file for instructions to ensure your python environment contains the requisite packages.

1. Run the following commands to encrypt each CSV file.

   ```bash
   python3 simple-csv-raw-to-enc.py --cryptoKeyName $cryptokeyname --wrappedKey $wrappedkey --input_file_path sample-100-raw.csv --output_file_path ../../encrypted_data/sample-100-encrypted.csv

   python3 simple-csv-raw-to-enc.py --cryptoKeyName $cryptokeyname --wrappedKey $wrappedkey --input_file_path NewCust.csv --output_file_path ../../encrypted_data/NewCust.csv

   python3 simple-csv-raw-to-enc.py --cryptoKeyName $cryptokeyname --wrappedKey $wrappedkey --input_file_path UpdCust.csv --output_file_path ../../encrypted_data/UpdCust.csv
   ```

   - Parameters:
     - `--cryptoKeyName`: Specifies the KMS crypto key for encryption.
     - `--wrappedKey`: Provides the wrapped encryption key.
     - `--input_file_path`: Path of the raw file to be encrypted.
     - `--output_file_path`: Path for saving the encrypted file.

   After running these commands, the encrypted files will be located in the `../../encrypted_data/` directory.

1. Remove service account impersonation from your session:

   ```bash
   gcloud auth application-default login
   ```

1. Navigate back to the project’s root directory:
   ```bash
   cd ../..
   ```
1. Set the environment variable for the target GCS bucket by running the following command, which retrieves the bucket name for data ingestion for domain-1 in the nonproduction environment from Terraform output:

   ```bash
   terraform -chdir="../gcp-projects/business_unit_4/nonproduction" init

   export data_ingestion_bucket=$(terraform -chdir="../gcp-projects/business_unit_4/nonproduction" output -json data_ingestion_buckets | jq -r '."domain-1"')
   ```
1. Use the `gsutil cp` command to upload each encrypted CSV file to the specified GCS bucket:
   ```bash
   gsutil cp encrypted_data/sample-100-encrypted.csv ${data_ingestion_bucket}/sample-100-encrypted.csv
   gsutil cp encrypted_data/NewCust.csv ${data_ingestion_bucket}/NewCust.csv
   gsutil cp encrypted_data/UpdCust.csv ${data_ingestion_bucket}/UpdCust.csv
   ```

## Deployment Continued...
1. Commit Changes
   ```bash
   git add .
   git commit -m 'Initialize data domain non confidential repo'
   ```

1. Push your plan branch
   ```bash
   git push --set-upstream origin plan
   ```

1. Create a PR request from `plan` to `nonproduction` in your GitHub Repository

1. Observe the plan in GCP Build by going to: https://console.cloud.google.com/cloud-build/builds;region=us-central1?hl=en&project=[prj-c-bu4-infra-gh-cb-ID-HERE]

1. Once the plan has been successfully satisfied, Merge your request and view the terraform apply here: https://console.cloud.google.com/cloud-build/builds;region=us-central1?hl=en&project=[prj-c-bu4-infra-gh-cb-ID-HERE]

## Ingesting Data into PubSub
In this part of the data ingestion process, data from a JSON file will be sent as Pub/Sub messages for further processing.

1.  Go to the `helpers/pubsub-job-emulator` folder and execute the following commands to initialize Terraform and send the JSON data to Pub/Sub:
      ```bash
      cd helpers/pubsub-job-emulator

      terraform -chdir="../gcp-projects/business_unit_4/nonproduction" init

      export ingest_project_id=$(terraform -chdir="../gcp-projects/business_unit_4/nonproduction" output -json data_domain_ingestion_projects | jq -r '."domain-1".project_id')
      ```

1. Read the instructions in the [README.md](helpers/pubsub-job-emulator/README.md) file in the pubsub-job-emulator directory for instructions to ensure your python environment contains the requisite packages.

1. Run the python code to send the data:
   ```bash
   python3 simple-pubsub-job.py --cryptoKeyName $cryptokeyname --wrappedKey $wrappedkey --messages_file ../sample-generator/sample-100-raw.json --project_id $ingest_project_id --topic_id data_ingestion
   ```
   - This will send data from `sample-100-raw.json` as messages to the Pub/Sub topic `data_ingestion` within the specified project.
   - The `cryptoKeyName` and `wrappedKey` are used to ensure that the data is encrypted during the ingestion process.

2. Once the data arrives on the landing services (PubSub) the Dataflow pipelines ingest the data. You can monitor the Pub/Sub payload jobs in the Pub/Sub Console:
   - Go to the `Metrics` tab for the specific Topic to view general message metrics.
   - Use the `Metrics` tab on the Subscription for detailed metrics.
   - To view messages in transit, click on the `Messages` tab and then the `PULL` button. (Note: Viewing messages in transit may delay processing.)

1. In the Dataflow Console, monitor the pipeline jobs that ingest, decrypt, transform, and re-encrypt the data.
   - Click on a specific Dataflow job to view step-by-step processing details.

1. After processing, the data lands in the BigQuery table within the `non-confidential` project.
   - To preview the data, in the BigQuery Query Console use the `Preview` tab for a quick data view.

   *NOTE:* Executing direct BQ console queries on `non-confidential` project is limited to `DEVELOMENT` environment. Querying data in `NON-PRODUCTION` and `PRODUCTION` environment, is via the `CONSUMER` project.

1. Only authorized users can view the masked and encrypted data fields. A user therefore needs to be in the apropriate group to be able to view these data fields. See [`Defined User Groups`](/5-app-infra/11-consumer-1/README.md#defined-user-groups) section for details.

1. A separate Dataflow pipeline moves data from the `non-confidential` project to the confidential project, where the data is decrypted and unmasked, existing in plain text format.
   - This pipeline can also be monitored in the `Dataflow Console` within the `confidential` project for step-by-step processing details.

1. In the `confidential` project, the data is accessible only to specific full-access users.
These users can query the data using a SELECT statement in BigQuery or view it through the Preview tab within the BigQuery table.

1. Once done, cd out of this folder
   ```bash
   cd ../../..
   ```


## Operational Environments
> The information presented below is reference for an operator to manage containers in a production environment.

In an operational environment, it is recommended to use the short SHA tags of images instead of environment-specific tags (e.g., `nonproduction`, `production`). Short SHAs provide a unique reference to each image version, enabling reliable traceability back to the specific commit used to build the image. This approach is particularly beneficial for managing production workloads, where consistent and repeatable deployments are essential.

For example, instead of using:

```
dataflow_template_jobs = {
  "bq_to_bq" = {
    "image_name"        = "samples/reidentify_bq_to_bq:nonproduction"
    "template_filename" = "reidentify_bq_to_bq-nonproduction.json"
    "additional_parameters" = {
      batch_size = 1000
    }
  },
}
```
A production configuration might specify the image and template filename with a short SHA tag, such as:

```
dataflow_template_jobs = {
  "bq_to_bq" = {
    "image_name"        = "samples/reidentify_bq_to_bq:123abc"
    "template_filename" = "reidentify_bq_to_bq-123abc.json"
    "additional_parameters" = {
      batch_size = 1000
    }
  },
}
```

By using a short SHA (`123abc` in this example) in place of the environment name, the job configuration is aligned with a specific version of the image. This approach not only improves traceability but also allows developers and operators to distinguish between multiple image versions, supporting effective version control and rollback strategies in production.

For the purposes of this example and to simplify the deployment process for multiple environments, the configurations default to using environment names (e.g., `nonproduction`). This setup streamlines initial testing and allows for faster iterations when managing multiple environments.


## Deployment Continued - Production (Optional)
The instructions provided here will demonstrate actions needed for a production deployment.  These are set as optional as the process is still time consuming and requires additional manual work.  In the previous steps, `nonproduction` was included as an example of what would be done in an operational environment, and the `production` environment, although part of of an operational environment, will increase the time required to complete the deployment process for this Data Mesh Example.

1. Gather the necessary variables needed:
   ```bash
   terraform -chdir="../gcp-projects/business_unit_4/production" init

   export data_ingestion_bucket=$(terraform -chdir="../gcp-projects/business_unit_4/production" output -json data_ingestion_buckets | jq -r '."domain-1"')

   echo "data_ingestion_bucket: ${data_ingestion_bucket}"
   ```
1. Use the `gsutil cp` command to upload each encrypted CSV file to the specified GCS bucket:
   ```bash
   gsutil cp encrypted_data/sample-100-encrypted.csv ${data_ingestion_bucket}/sample-100-encrypted.csv
   gsutil cp encrypted_data/NewCust.csv ${data_ingestion_bucket}/NewCust.csv
   gsutil cp encrypted_data/UpdCust.csv ${data_ingestion_bucket}/UpdCust.csv
   ```

1. Create a PR request from `nonproduction` to `production` in your GitHub Repository

1. Observe the plan in GCP Build by going to: https://console.cloud.google.com/cloud-build/builds;region=us-central1?hl=en&project=[prj-c-bu4-infra-gh-cb-ID-HERE]

1. Once your plan has been satisfied, Merge your request and view the terraform apply here: https://console.cloud.google.com/cloud-build/builds;region=us-central1?hl=en&project=[prj-c-bu4-infra-gh-cb-ID-HERE]

## Ingesting Data into PubSub - Production (Optional)
This process is to ingest data in a production environment.  As stated above, this is an optional step, as the process is still time consuming and requires additional manual work, increasing the time required to complete the deployment process for this Data Mesh Example.

1.  Go to the `helpers/pubsub-job-emulator` folder and execute the following commands to initialize Terraform and send the JSON data to Pub/Sub:
      ```bash
      cd helpers/pubsub-job-emulator

      terraform -chdir="../gcp-projects/business_unit_4/production" init

      export ingest_project_id=$(terraform -chdir="../gcp-projects/business_unit_4/production" output -json data_domain_ingestion_projects | jq -r '."domain-1".project_id')

      echo "ingest_project_id: ${ingest_project_id}"
      ```

1. Read the instructions in the [README.md](helpers/pubsub-job-emulator/README.md) file in the pubsub-job-emulator directory for instructions to ensure your python environment contains the requisite packages.

1. Run the python code to send the data:
   ```bash
   python3 simple-pubsub-job.py --cryptoKeyName $cryptokeyname --wrappedKey $wrappedkey --messages_file ../sample-generator/sample-100-raw.json --project_id $ingest_project_id --topic_id data_ingestion
   ```
   - This will send data from `sample-100-raw.json` as messages to the Pub/Sub topic `data_ingestion` within the specified project.
   - The `cryptoKeyName` and `wrappedKey` are used to ensure that the data is encrypted during the ingestion process.

2. Once the data arrives on the landing services (PubSub) the Dataflow pipelines ingest the data. You can monitor the Pub/Sub payload jobs in the Pub/Sub Console:
   - Go to the `Metrics` tab for the specific Topic to view general message metrics.
   - Use the `Metrics` tab on the Subscription for detailed metrics.
   - To view messages in transit, click on the `Messages` tab and then the `PULL` button. (Note: Viewing messages in transit may delay processing.)

1. In the Dataflow Console, monitor the pipeline jobs that ingest, decrypt, transform, and re-encrypt the data.
   - Click on a specific Dataflow job to view step-by-step processing details.

1. After processing, the data lands in the BigQuery table within the `non-confidential` project.
   - To query and view the data, you can run a `SELECT` statement in the BigQuery Query Console or use the `Preview` tab for a quick data view.

1. Certain fields in the data are masked or encrypted. Only authorized users within specific access can view this sensitive data.

1. A separate Dataflow pipeline moves data from the `non-confidential` project to the confidential project, where the data is decrypted and unmasked, existing in plain text format.
   - This pipeline can also be monitored in the `Dataflow Console` within the `confidential` project for step-by-step processing details.

1. In the `confidential` project, the data is accessible only to specific full-access users.
These users can query the data using a SELECT statement in BigQuery or view it through the Preview tab within the BigQuery table.

Once done, cd out of this folder
   ```bash
   cd ../../..
   ```