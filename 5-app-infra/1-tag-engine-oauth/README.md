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

## Tag Engine Oauth

Tag Engine will run as a Cloud Run Service in the `data-governance` project.  In order for the API to receive requests, every call must be authenticated using OAuth.

The service will use access tokens for authorization. The API service expects the client to pass in an access token when calling the API functions (`gcloud auth print-identity-token`).Note that a client secret file is required for the OAuth flow.

A secret has already been created in `1-org` which now needs to be manually filled with the Oauth Client credentials.

1. Gather your data governance project id:

   ```bash
   export data_governance_project_id=$(terraform -chdir="gcp-projects/business_unit_4/shared" output -raw data_governance_project_id)

   echo $data_governance_project_id
   ```
1. Create an OAuth client:

   Open [API Credentials](https://console.cloud.google.com/apis/credentials).<br>

1. Ensure you have selected your data-governance project in the `common` folder.

1. Configure your Consent Screen.  There is a button on the right of the screen that says `Configure consent screen`.
   Configure your consent screen with _at least_ the following options:
      - **AppUser Type**: Internal
      - **App Name** : tag-engine-oauth
      - **User Support Email**: [a valid email address]
      - **Developer Contact Information**: [a valid email address]


   Ensure you have selected `.../auth/userinfo.email`, `openid` and `.../auth/cloud-platform` as OAuth scopes.

   Click on Create Credentials and select OAuth client ID and choose the following settings:

   - **Application type**: web application
   - **Name**: tag-engine-oauth
   - **Authorized redirects URIs**: Leave this field blank for now.
   - Click Create
   - Download the credentials as `te_client_secret.json` and place the file in the root of this folder<br>

1. Add the `ts_client_secret.json` file as a gcp secret.  Change Directory into this folder and execute the following:
   ```bash

   cd 5-app-infra/1-tag-engine-oauth

   export common_secrets_project_id=$(terraform -chdir="gcp-projects/business_unit_4/shared" output -raw common_secrets_project_id)

   export org_tf_sa=$(terraform -chdir="gcp-bootstrap/envs/shared" output -raw organization_step_terraform_service_account_email)

   export tag_engine_oauth_client_id_secret_name=$(terraform -chdir="gcp-projects/business_unit_4/shared" output -raw tag_engine_oauth_client_id_secret_name)
   ```
   ```bash
   echo "common_secrets_project_id: ${common_secrets_project_id}"
   echo "org_tf_sa: ${org_tf_sa}"
   echo "tag_engine_oauth_client_id_secret_name: ${tag_engine_oauth_client_id_secret_name}"
   ```
   Impersonate the organization terraform service account to create the keyset:
   ```bash
   gcloud auth application-default login --impersonate-service-account=${org_tf_sa}
   ```

   ```bash
   cat te_client_secret.json | gcloud secrets versions add "${tag_engine_oauth_client_id_secret_name}" \
      --data-file=- \
      --project="${common_secrets_project_id}"
   ```
   Remove impersonation:
   ```bash
   gcloud auth application-default login
   ```
