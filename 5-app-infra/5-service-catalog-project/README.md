# 5-app-infra

This repo is part of a multi-part guide that shows how to configure and deploy
the example.com reference architecture described in
[Google Cloud security foundations guide](https://cloud.google.com/architecture/security-foundations). The following table lists the parts of the guide.

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

## Purpose
The main purpose of this project is to inflate the Service Catalog project in the Common environment with the Cloud Storage Bucket for the Service Catalog artifacts (Terraform solutions) and the Cloud Build pipeline to builds and copy the solutions to the bucket. Additionally, a Cloud Build logging bucket is created and corresponding IAM roles applied.

Although Service Catalog itself must be manually deployed, the solution build process can be automated.

The repository has the structure similar to other repositories, such as `4-projects` with just one environment sub-folder - `production` as the Service Catalog project is created in the Common environment, so considered as production:
   ```
   envs
   ├── production
   modules
   ├── service_catalog
   │   ├── README.md
   │   ├── data.tf
   │   ├── main.tf
   │   ├── outputs.tf
   │   ├── variables.tf
   │   └── versions.tf
   policy-library
   ...
   ```

The pipeline that is running Terraform code in this repository can be accessed by navigating to the project name created in step-4:

```bash
terraform -chdir="gcp-projects/business_unit_4/shared/" output -json service_catalog | jq -r '.project_id'
```

### Deploying with Cloud Build

1. Clone the `bu4-service-catalog` repo.

   ```bash
   git clone git@github.com:[git-owner-name]/gcp-dm-bu4-prj-service-catalog.git bu4-service-catalog
   ```

1. Navigate into the repo, change to non-main branch and copy contents of foundation to new repo.
   All subsequent steps assume you are running them from the bu4-service-catalog directory.
   If you run them from another directory, adjust your copy paths accordingly.

   ```bash
   cd bu4-service-catalog
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

1. Copy contents to the new repo

   ```bash
   cp -R ../gcp-data-mesh-foundations/5-app-infra/5-service-catalog-project/* .
   ```

1. Update the file with values from your 0-bootstrap.

   ```bash
   export remote_state_bucket=$(terraform -chdir="../gcp-bootstrap/envs/shared" output -raw projects_gcs_bucket_tfstate)
   echo "remote_state_bucket = ${remote_state_bucket}"

   sed -i'' -e "s/REMOTE_STATE_BUCKET/${remote_state_bucket}/" ./common.auto.tfvars
   ```

1. Update `backend.tf` with your bucket from the infra pipeline output.

   ```bash
   export backend_bucket=$(terraform -chdir="../gcp-projects/business_unit_4/shared/" output -json state_buckets | jq '."service-catalog"' --raw-output)
   echo "backend_bucket = ${backend_bucket}"

   for i in `find . -name 'backend.tf'`; do sed -i'' -e "s/UPDATE_APP_INFRA_BUCKET/${backend_bucket}/" $i; done
   ```
1. Commit changes.

   ```bash
   git add .
   git commit -m 'Initialize repo'
   ```

1. Push your plan branch
   ```bash
   git push --set-upstream origin plan
   ```

1. Create a PR request from `plan` to `production` in your GitHub Repository

1. Observe the plan in GCP Build by going to: https://console.cloud.google.com/cloud-build/builds;region=us-central1?hl=en&project=[prj-c-bu4-infra-gh-cb-ID-HERE]

1. Once the plan has been satisfied, Merge your request and view the terraform apply here: https://console.cloud.google.com/cloud-build/builds;region=us-central1?hl=en&project=[prj-c-bu4-infra-gh-cb-ID-HERE]

1. `cd` out of the `bu4-service-catalog` repository.
   ```bash
   cd ..
   ```
