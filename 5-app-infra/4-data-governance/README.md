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

For an overview of the architecture and the parts, see the
[placeholder](https://github.com/placeholder)
file.

# Data Governance
Repository for data governance

## Requirements
Ensure you have the following binaries installed before proceeding:

- [Tinkey](https://developers.google.com/tink/tinkey-overview) version 1.11.0 or later
- [Java](https://www.oracle.com/java/technologies/downloads/) version 11 or later
- [jq](https://stedolan.github.io/jq/) version 1.6 or later

## Deploying gcp-dm-bu4-prj-data-governance

1. clone your repository that was created in 4-projects
   ```bash
   git clone git@github.com:[git-owner-name]/gcp-dm-bu4-prj-data-governance.git bu4-data-governance
   ```

1. cd over to the `bu4-data-governance` directory
    ```bash
    cd bu4-data-governance
    ```
1. Seed the repository if it has not been initialized yet.

   ```bash
   git commit --allow-empty -m 'repository seed'
   git push --set-upstream origin main

   git checkout -b production
   git push --set-upstream origin production

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
   cp -R ../gcp-data-mesh-foundations/5-app-infra/4-data-governance/* .
   ```

1. Update the `backend.tf` files with the backend bucket from step Projects.
    ```bash
    export backend_bucket=$(terraform -chdir="../gcp-projects/business_unit_4/shared" output  -json state_buckets | jq -r '."data-governance"')
    for i in `find . -name 'backend.tf'`; do sed -i'' -e "s/UPDATE_APP_INFRA_BUCKET/${backend_bucket}/" $i; done
    ```
1. Update `remote_state_bucket` in common.auto.tfvars
   ```bash
   export remote_state_bucket=$(terraform -chdir="../gcp-bootstrap/envs/shared" output -raw projects_gcs_bucket_tfstate)
   sed -i'' -e "s/REMOTE_STATE_BUCKET/${remote_state_bucket}/" common.auto.tfvars
   ```

1. Before continuing, gather the necessary variables needed to perform the following tasks.
   ```bash
   export kms_key=$(terraform -chdir="../gcp-projects/business_unit_4/shared" output -json deidentify_keys | jq -r '."deidenfication_key_common-us-central1"')
   export common_secrets_project_id=$(terraform -chdir="../gcp-projects/business_unit_4/shared" output -raw common_secrets_project_id)
   export wrapper_secret_name=$(terraform -chdir="../gcp-projects/business_unit_4/shared" output -raw kms_wrapper_secret_name)
   export org_tf_sa=$(terraform -chdir="../gcp-bootstrap/envs/shared" output -raw organization_step_terraform_service_account_email)
   export dlp_wrapper_secret_name=$(terraform -chdir="../gcp-projects/business_unit_4/shared" output -raw dlp_kms_wrapper_secret_name)
   ```
   ```bash
   echo "kms_key: ${kms_key}"
   echo "common_secrets_project_id: ${common_secrets_project_id}"
   echo "wrapper_secret_name: ${wrapper_secret_name}"
   echo "org_tf_sa: ${org_tf_sa}"
   echo "dlp_wrapper_secret_name: ${dlp_wrapper_secret_name}"
   ```

1. Install `tinkey`.  [Please read the instructions provided by the official documentations](https://developers.google.com/tink/tinkey-overview#installation)

1. Impersonate the organization terraform service account to create the keyset:
   ```bash
   gcloud auth application-default login --impersonate-service-account=${org_tf_sa}
   ```

1. Create a wrapped key to dump into a secret.  We will use `tinkey` to create a keyset to be used for de-identification.
   The kms key which will serve as a master key has already been created in `gcp-projects`.  What is left now is to use this key to create an encrypted wrapper.
   First we will create a random key and base64 encode it

   Use cloudmks to wrap the key using `tinkey`
   ```bash
   tinkey create-keyset \
      --key-template AES256_GCM \
      --out-format json \
      --out ./keyset.json \
      --master-key-uri "gcp-kms://${kms_key}"
   ```
1. Create a secret with the newly captured cipher (wrapper) that has just been made. This will be used in the ingestion pipelines in a later module
   ```bash
   cat keyset.json | gcloud secrets versions add "${wrapper_secret_name}"  \
      --data-file=- \
      --project="${common_secrets_project_id}"
   ```

1. Create a 128-, 192-, or 256-bit AES key. The following command uses openssl to create a 256-bit key.  This will be used for the DLP templates
   ```bash
   openssl rand -out "./aes_key.bin" 32
   keyset=$(base64 -i ./aes_key.bin)
   cipher=$(curl -X POST "https://cloudkms.googleapis.com/v1/${kms_key}:encrypt" \
      -H "Authorization: Bearer $(gcloud auth application-default print-access-token)" \
      -H "content-type: application/json" \
      --data "{\"plaintext\": \"${keyset}\"}" | jq -r '.ciphertext')

   echo -n $cipher | gcloud secrets versions add "${dlp_wrapper_secret_name}" \
      --data-file=- \
      --project="${common_secrets_project_id}"
   ```

1. Stop impersonating the organization terraform service account
   ```bash
   gcloud auth application-default login
   ```

1. Commit Changes
   ```bash
   git add .
   git commit -m 'Initialize data governance repo'
   ```

1. Push your plan branch
   ```bash
   git push --set-upstream origin plan
   ```

1. Create a PR request from `plan` to `production` in your GitHub Repository

1. Observe the plan in GCP Build by going to: https://console.cloud.google.com/cloud-build/builds;region=us-central1?hl=en&project=[prj-c-bu4-infra-gh-cb-ID-HERE]

1. Once the plan has been satisfied, Merge your request and view the terraform apply here: https://console.cloud.google.com/cloud-build/builds;region=us-central1?hl=en&project=[prj-c-bu4-infra-gh-cb-ID-HERE]

1. Once done, cd out of this folder
   ```bash
   cd ..
   ```

