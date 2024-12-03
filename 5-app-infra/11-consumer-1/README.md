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


# Consumer Project
Repository for consumer-1

## Deploying gcp-dm-bu4-prj-consumer-1

1. clone your repository that was created in 4-projects
   ```bash
   git clone git@github.com:[git-owner-name]/gcp-dm-bu4-prj-consumer-1.git bu4-prj-consumer-1
   ```

1. cd over to the `bu4-prj-consumer-1` directory
   ```bash
   cd bu4-prj-consumer-1
   ```

1. Seed the repository if has no been initialized yet.
   ```bash
   git commit --allow-empty -m 'repository seed'
   git push --set-upstream origin main

   git checkout -b production
   git push --set-upstream origin production

   git checkout -b nonproduction
   git push --set-upstream origin nonproduction

   git checkout -b development
   git push --set-upstream origin development

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
   cp -R ../gcp-data-mesh-foundations/5-app-infra/11-consumer-1/* .
   ```

1. Update the `backend.tf` files with the backend bucket from step Projects.
    ```bash
    export backend_bucket=$(terraform -chdir="../gcp-projects/business_unit_4/shared" output  -json state_buckets | jq -r '."consumer-1"')
    for i in `find . -name 'backend.tf'`; do sed -i'' -e "s/UPDATE_APP_INFRA_BUCKET/${backend_bucket}/" $i; done
    ```

1. Update `remote_state_bucket` in common.auto.tfvars
   ```bash
   export remote_state_bucket=$(terraform -chdir="../gcp-bootstrap/envs/shared" output -raw projects_gcs_bucket_tfstate)
   sed -i'' -e "s/REMOTE_STATE_BUCKET/${remote_state_bucket}/" common.auto.tfvars
   ```

1. Commit Changes
   ```bash
   git add .
   git commit -m 'Initialize consumer-1 repo'
   ```

1. Push your plan branch
   ```bash
   git push --set-upstream origin plan
   ```

1. Create a PR request from `plan` to `development` in your GitHub Repository

1. Observe the plan in GCP Build by going to: https://console.cloud.google.com/cloud-build/builds;region=us-central1?hl=en&project=[prj-c-bu4-infra-gh-cb-ID-HERE]

1. Merge `development` to `nonproduction` and observe the terraform apply in GCP build here: https://console.cloud.google.com/cloud-build/builds;region=us-central1?hl=en&project=[prj-c-bu4-infra-gh-cb-ID-HERE]

1. Merge `nonproduction` to `production` and observe the terraform apply in GCP build here: https://console.cloud.google.com/cloud-build/builds;region=us-central1?hl=en&project=[prj-c-bu4-infra-gh-cb-ID-HERE]

1. Once done, cd out of this folder
   ```bash
   cd ..
   ```

# Data Access Management API

>In `4-data-governance` a Data Access API was created to manage data access permissions.  Below, there is information and a guide on how to utilize this API.

## Defined User Groups
- cdmc-conf-data-viewer
- cdmc-data-viewer
- cdmc-masked-data-viewer
- cdmc-fine-grained-data-viewer
- cdmc-encrypted-data-viewer

The above user groups are created at the organizational level. According to their respective roles in the organization, only users in these specific groups can access the data.

These groups must have the Data Access Management Service Account and the Approvers as owners. The Service Account ownership must be given through the Google Cloud Console IAM & Admin.
1. Select the Organization, under the Select a Resource Dropdown. And navigate to `Cloud Console IAM & Admin `![](/5-app-infra/11-consumer-1/images/IAM_ADMIN_Organization.png)

2. On the Right Menu, click on `Groups`![](/5-app-infra/11-consumer-1/images/IAM_ADMIN_Groups.png) 

3. Grab the Data Access Management API service account on your Governance Project. The service account is data-access-management@DATA_GOVERNANCE_PROJECT_ID.iam.gserviceaccount.com. Replace the **DATA_GOVERNANCE_PROJECT_ID** with your Governance Project ID.![](/5-app-infra/11-consumer-1/images/IAM_API_Service_Account.png)

4. Finally, you can add the Data Access Management API service account as the group **OWNER** for each one. ![](/5-app-infra/11-consumer-1/images/IAM_ADMIN_Add_Members.png)


### **Consumers Group and Roles**

* **Data Viewers:** 
Users who can access non-confidential data.
    * **BigQuery Data Viewer** - roles/bigquery.dataViewer
    * **BigQuery Job User** - roles/bigquery.jobUser

* **Encrypted Data Viewers:** 
Users who can access non-confidential data with sensitive encrypted data.
    * **Cloud KMS CryptoKey Decrypter Via Delegation** - roles/cloudkms.cryptoKeyDecrypterViaDelegation

* **Fine-Grained Data Viewers:** 
Users can access protected data by column-level access control.
    * **Fine-Grained Reader** - roles/datacatalog.categoryFineGrainedReader

* **Masked Data Viewers:** 
Users who can access non-confidential data with sensitive data masked.
    * **Masked Reader** - roles/bigquerydatapolicy.maskedReader

* **Confidential Data Viewers:** 
Users who can access confidential data.
    * **BigQuery Data Viewer** - roles/bigquery.dataViewer
    * **BigQuery Job User** - roles/bigquery.jobUser


### Requester Endpoints

1. **Navigate to the Data Governance Project** in the Google Cloud Console, and go to `Cloud Run`.

2. **Identify Data Access Management API**: Locate the API that begins with `data-access-management-api-`. Each API is designed to manage access for a specific dataset ingested into your data domain.

3. **Copy the URL**: For each of the `data-access-management-api-` API, click on the `Copy to clipboard` button next ot the `URL` link.

4. **Export the Variable DATA_ACCESS_MANAGEMENT_API with the URL From the Previous Step, and Run the Following Commands in the Terminal to Request a Specific Role**:
    ```shell
    curl \
        --location "${DATA_ACCESS_MANAGEMENT_API}/v1/permission-requests/users" \
        --header 'Content-Type: application/json' \
        --header "Authorization: Bearer $(gcloud auth print-identity-token)" \
        --data '{"roles": ["roles/bigquerydatapolicy.maskedReader"]}'
    ```

### Approver Endpoints

1. **Navigate to Cloud Run**: Access the Google Cloud Console, and go to `Cloud Run`.

2. **Identify Data Access Management API**: Locate the API that begins with `data-access-management-api-`. Each API is designed to manage access for a specific dataset ingested into your data environment.

3. **Copy the URL**: For each of the `data-access-management-api-` API, click on the `Copy to clipboard` button next ot the `URL` link.

4. **Export the Variable DATA_ACCESS_MANAGEMENT_API with the URL From the Previous Step, and Run the Following Commands in the Terminal to List all Permission Requests**:
    ```shell
      curl -X GET \
    --location "${DATA_ACCESS_MANAGEMENT_API}/v1/permission-requests/" \
    --header "Authorization: Bearer $(gcloud auth print-identity-token)"
    ```

5. **Export the Variable DATA_ACCESS_MANAGEMENT_API with the URL From the Previous Step, and REQUEST_ID with the ID of the Permission Request, and Run the Following Commands in the Terminal to Approve a Specific Request**:
    ```shell
      curl -X PUT \
    --location "${DATA_ACCESS_MANAGEMENT_API}/v1/permission-requests/${REQUEST_ID}/approve" \
    --header "Authorization: Bearer $(gcloud auth print-identity-token)"
    ```

6. **Export the Variable DATA_ACCESS_MANAGEMENT_API with the URL From the Previous Step, and REQUEST_ID with the ID of the Permission Request, and Run the Following Commands in the Terminal to Deny a Specific Request***:
    ```shell
      curl -X PUT \
    --location "${DATA_ACCESS_MANAGEMENT_API}/v1/permission-requests/${REQUEST_ID}/deny" \
    --header "Authorization: Bearer $(gcloud auth print-identity-token)"
    ```

## Requirements
To be included in a consumer group, you must first submit a request to the Data Management API, and wait for the approval from a group owner. For detailed instructions on how to request membership, please refer to the following link.
* **Link:** [Data Management API](https://github.com/badal-io/gcp-data-mesh-foundations/blob/main/5-app-infra/3-artifact-publish/docker/cdmc/data_access_management_api/README.md)

Once your request is approved, you will be granted access to the groups and their associated permissions.

### - cdmc-conf-data-viewer
Highest level authentication to access data. Users added to this group can directly access confidential data that is stored in its raw format, in the confidential project.

Example Query:
```
SELECT * FROM `<confidential_project_id>.<dataset_id>.<table_id>` LIMIT 10;
```

### - cdmc-data-viewer
Lowest level access to data. Users added to this group can access raw data that is non-sensitive and stored in the non-confidential project. While the users can query the de-identified fields, they do not have any access to query the masked fields. Users will therefore have to use the `except` function to avoid the masked field in their queries. Data in the de-identified fields will be visible as encrypted.

Example Query:
```
SELECT * EXCEPT(Card_Holders_Name) FROM `<non_confidential_project_id>.<dataset_id>.<table_id>` LIMIT 10;
```

### - cdmc-masked-data-viewer
Users added to this group have similar access as the `cdmc-data-viewer` group with the exception that they can query the masked field. However, the values from the masked field are displayed in encrypted format to the users, similar to the de-identified fields.

Example Query:
```
SELECT * FROM `<non_confidential_project_id>.<dataset_id>.<table_id>` LIMIT 10;
```

### - cdmc-fine-grained-data-viewer
Users added to this group have similar access as the `cdmc-masked-data-viewer` group. The difference in these users is that they can actually see the raw value of the masked field. The values in the de-identified fields is still displayed as encrypted.

Example Query:
```
SELECT * FROM `<non_confidential_project_id>.<dataset_id>.<table_id>` LIMIT 10;
```

### - cdmc-encrypted-data-viewer
Users added to this group have similar access as the `cdmc-data-viewer` group with the exception that they can query and view the de-identified field data in raw format. While the users can query and view the de-identified fields, they do not have any access to query the masked fields. Users will therefore have to use the `except` function to avoid the masked field in their queries.
To be able to re-identify the data in de-identified fields, the users will first have to retrieve the wrapped key in bytes, and use this wrapped key in combination with the kms key name. The wrapped key and the kms key should be the same ones that have been used to de-identify the data in the respective fields. 
The following python script should allow the user to retrieve the wrapped key in binary format. This key can then be used in the query, as shown in the example below.

Python Script:
```
python ./get_wrapped_key_bytes --wrapped_key projects/<project_id>/secrets/<secret_name>/versions/<version>
```
Sample output:
```
%> python ./get_wrapped_key_bytes.py --wrapped_key projects/<project_id>/secrets/<secrect_name>/versions/<version>
b'\n$\x00<e|5\x9c"\xab?\xac\'o\xa5\xeb\xb8\xee4\xf0\xb9&+v&\x1d\xdd:\x85\x11\xd0.\xe3\x9b\xeby\x8c\xc0\x12A\x00sa;\xd8\xe0>\x99\x13\xc4\xc1\xa6\xacn\xfa\xaa\xef\xb0\xa1\xd1\n\n\xa7\x91\xb6\xd8\x02\x9cE\xc5\xad\xebfZ\xfe\xe82\xcc*c>\xef\x0f\xb4$\xdek\x95\x8bu\t\xa9\xe2\xf2<\\\x0bI\x1aw66\\m7'
```

Example Query:
```
CREATE TEMP FUNCTION decrypt_data(encodedText STRING)
            RETURNS STRING
                AS (
                    DLP_DETERMINISTIC_DECRYPT(
                        DLP_KEY_CHAIN(
                            "gcp-kms://projects/<project_id>/locations/<location>/keyRings/<keyRings>/cryptoKeys/<cryptoKeys>",
                            <wrapped_key_from_script_output>
                        ),
                    encodedText,  
                    ''  
                ) 
        );

        SELECT 
          Card_Type_Code,
          Issuing_Bank,
          Card_Number,
          decrypt_data(Card_Number) as decrypted_Card_Number,
          Card_PIN,
          decrypt_data(Card_PIN) as decrypted_Card_PIN, 
          Credit_Limit
        FROM 
          `<non_confidential_project_id>.<dataset_id>.<table_id>`;
```
