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

# Data Domain 1 Confidential
Repository for domain-1-confidential

## Deploying gcp-dm-bu4-prj-domain-1-conf

1. clone your repository that was created in 4-projects
   ```bash
   git clone git@github.com:[git-owner-name]/gcp-dm-bu4-prj-domain-1-conf.git bu4-prj-domain-1-conf
   ```

1. cd over to the `bu4-prj-domain-1-conf` directory
    ```bash
    cd bu4-prj-domain-1-conf
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
   cp -R ../gcp-data-mesh-foundations/5-app-infra/9-data-domain-1-confidential/* .
   ```

1. Update the `backend.tf` files with the backend bucket from step Projects.
    ```bash
    export backend_bucket=$(terraform -chdir="../gcp-projects/business_unit_4/shared" output  -json state_buckets | jq -r '."domain-1-conf"')
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

1. Update `dataflow_gcs_bucket_url` in common.auto.tfvars. This contains the templates created in `bu4-prj-artifacts`
   ```bash
   terraform -chdir="../bu4-prj-artifacts/envs/shared" init
   export gcs_bucket_url=$(terraform -chdir="../bu4-prj-artifacts/envs/shared" output -json gcs_template_bucket | jq -r .url)
   sed -i'' -e "s|UPDATE_TEMPLATE_BUCKET_URL|${gcs_bucket_url}|" common.auto.tfvars
   ```

1. Commit Changes
   ```bash
   git add .
   git commit -m 'Initialize data domain confidential repo'
   ```

1. Push your plan branch
   ```bash
   git push --set-upstream origin plan
   ```

1. Create a PR request from `plan` to `nonproduction` in your GitHub Repository

1. Observe the plan in GCP Build by going to: https://console.cloud.google.com/cloud-build/builds;region=us-central1?hl=en&project=[prj-c-bu4-infra-gh-cb-ID-HERE]

1. Once the plan has been satisfied, Merge your request and view the terraform apply here: https://console.cloud.google.com/cloud-build/builds;region=us-central1?hl=en&project=[prj-c-bu4-infra-gh-cb-ID-HERE]

1. (Optional). If you have decided to use the Optional Production Deployment in [8-data-domain-1-ingest](../8-data-domain-1-ingest/README.md), Create a PR request from `plan` to `nonproduction` in your GitHub Repository

1. (Optional).  If you have decided to use the Optional Production Deployment in [8-data-domain-1-ingest](../8-data-domain-1-ingest/README.md), Merge `nonproduction` to `production` and observe the terraform apply in GCP build here: https://console.cloud.google.com/cloud-build/builds;region=us-central1?hl=en&project=[prj-c-bu4-infra-gh-cb-ID-HERE]

### Operational Environments

In an operational environment, it is recommended to use the short SHA tags of images instead of environment-specific tags (e.g.,`nonproduction`). Short SHAs provide a unique reference to each image version, enabling reliable traceability back to the specific commit used to build the image. This approach is particularly beneficial for managing production workloads, where consistent and repeatable deployments are essential.

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


Once finished, cd out of this folder
   ```bash
   cd ..
   ```