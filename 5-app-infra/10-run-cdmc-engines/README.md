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

### Introduction

At this stage, data has been successfully ingested into both the Non-Confidential and Confidential domain projects. In the `data-governance` project, the CDMC engines have been deployed and are now ready for execution.

To ensure a smooth data governance workflow, you must run each engine in sequence. Begin with the **Data Scanning and Quality Engine**, followed by the **Tag Engine**, **Record Manager**, and finally the **Report Engine**.

All tasks detailed in this document should be executed within the `Data Governance` project.

## Running the CDMC Engines

In the Google Cloud Console, select your `Data Governance` Project.

## Data Scanning and Quality Engine
1. **Navigate to Cloud Run**: Access the Google Cloud Console, go to `Cloud Run`, and select the `Jobs` tab.
2. **Identify Data Quality Jobs**: Locate the two jobs that begin with `dq-scanning`. Each job is designed to scan a specific dataset that has been ingested into your data environment.
3. **Execute Jobs**: For each of the `dq-scanning` jobs, click on the scanning job.  This will bring you to the job details page. Then, click on the `Execute` button to initiate the job. Allow each job to complete fully. You can monitor progress in real-time in the job details panel, and any logs generated will be accessible under the `Logs` tab.
4. **Trigger Inspection**: Next navigate to `Sensitive Data Protection`, and select the `INSPECTION` tab.![](/5-app-infra/10-run-cdmc-engines/images/Inspection_paused.png) 
If the `Job Triggers` status is in `Paused` state, select each `Trigger ID`; on the `Trigger details` page, then click `RUN NOW` and then `RESUME`.![](/5-app-infra/10-run-cdmc-engines/images/Trigger_Healthy.png) 

This should get the jobs set to a status of `Healthy` state.

#### *NOTE:* It is important to confirm the data quality and scanning jobs ran successfully in order for the following engines to execute without errors. See [`Validation`](/5-app-infra/10-run-cdmc-engines/README.md#validate-data-scanning-and-quality-output) steps below to additionally ensure successful execution of these processes ####

## Tag Engine

1. **Access Workflows**: In the Google Cloud Console, navigate to the `Workflows` section.
2. **Locate Tagging Workflows**: Within the list, identify the two workflows that begin with `caller-workflow`. These workflows are designed to scan and tag each ingested dataset individually.
3. **Execute and Monitor Workflows**: Select each `caller-workflow` and click `Execute` to initiate it. Note that these workflows can take approximately 30 to 45 minutes to complete, depending on dataset size and processing requirements. During execution, you can monitor progress by selecting the workflow and viewing the `Steps` tab, where the status of each step will be displayed.


## Record Manager

1. **Go to Cloud Run**: In the Google Cloud Console, navigate to `Cloud Run` and select the `Jobs` tab.
2. **Identify the Record Manager Job**: Look for a job prefixed with `record-manager`, which manages records for all datasets ingested into the current environment. This example assumes the environment is set to `nonproduction`.
3. **Execute the Record Manager Job**: Click on the `Execute` button to run this job. Allow the job to complete, observing any logs or messages generated in real-time to ensure that the job performs as expected.

## Report Engine

1. **Navigate to Workflows**: In the Google Cloud Console, access the `Workflows` section.
2. **Locate the Reporting Workflow**: Look for the workflow named `generate-report`. This workflow is configured to process reports for all datasets in the specified environment. In this example, it will run for the `nonproduction` environment.
3. **Run and Monitor the Workflow**: Select the `generate-report` workflow and click `Execute` to start the report generation process. Monitor the workflow’s progress, as completion times may vary. Check the `Steps` tab to track each stage of execution and ensure that the report is generated successfully.



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


1. **Navigate to Cloud Run**: Access the Google Cloud Console, and go to `Cloud Run`.

2. **Identify Data Access Management API**: Locate the API that begins with `data-access-management-api-`. Each API is designed to manage access for a specific dataset ingested into your data environment.

3. **Copy the URL**: For each of the `data-access-management-api-` API, click on the `Copy to clipboard` button next ot the `URL` link.

4. **Replace the Variable {data_access_management_api} with the URL From the Previous Step, and Run the Following Commands in the Terminal to Request a Specific Role**:
    ```shell
    curl \
      --location "{data_access_management_api}/v1/permission-requests/users" \
      --header 'Content-Type: application/json' \
      --header "Authorization: Bearer $(gcloud auth print-identity-token)" \
      --data '{"roles": ["roles/bigquerydatapolicy.maskedReader"]}'
    ```

5. **Replace the Variable {data_access_management_api} with the URL From the Previous Step, and {request_id} with the ID of the Permission Request, and Run the Following Commands in the Terminal to Approve a Specific Request**:
    ```shell
    curl -X PUT \
      --location "{data_access_management_api}/v1/permission-requests/{request_id}/approve" \
      --header "Authorization: Bearer $(gcloud auth print-identity-token)"
    ```

6. **Replace the Variable {data_access_management_api} with the URL From the Previous Step, and {request_id} with the ID of the Permission Request, and Run the Following Commands in the Terminal to Deny a Specific Request**:
    ```shell
    curl -X PUT \
      --location "{data_access_management_api}/v1/permission-requests/{request_id}/deny" \
      --header "Authorization: Bearer $(gcloud auth print-identity-token)"
    ```
7. **Replace the Variable {data_access_management_api} with the URL From the Previous Step, and Run the Following Commands in the Terminal to List all Permission Requests**:
    ```shell
    curl -X GET \
      --location "{data_access_management_api}/v1/permission-requests/" \
      --header "Authorization: Bearer $(gcloud auth print-identity-token)"
    ```
You can monitor progress in real-time in the job details panel, and any logs generated will be accessible under the `Logs` tab.

## Validate Data Scanning and Quality Output
After the Data Quality and Scanning engines are run, to ensure jobs have executed successfully, in the GCP console, navigate to `Cloud Run`. Under the `JOBS`![](/5-app-infra/10-run-cdmc-engines/images/DQ_Scanning_RecordManager.png) tab, it should list and show `Succeeded` status for the dq-scanning jobs, ensuring the jobs ran successfully.

The Data Scanning results can be viewed in the GCP portal under the Sensitive Data Protection's `Inspection`![](/5-app-infra/10-run-cdmc-engines/images/DLP_Inspection.png) section.
By clicking on the latest triggered job with a `Done` state shows the health of the data scanned. Here are some samples of the scanning output.

`Sample 1`![](/5-app-infra/10-run-cdmc-engines/images/DLP_Scanning_Sample1.png)
`Sample 2`![](/5-app-infra/10-run-cdmc-engines/images/DLP_Scanning_Sample2.png)

The Data Quality results can be viewed in the BQ dataset `cloud_dq_*` tables; `dq_summary` and `results`, respectively. These tables capture dimensions such as `completeness`, `duplication`, and `conformance`, to name a few, for the source data tables.

## Validate Tagging Engine Output
Tag engine's invoking is configured through `Workflows`![](/5-app-infra/10-run-cdmc-engines/images/Workflows.png) and can be monitored via the GCP Console by navigating to the `Workflows` service. Clicking on a workflow and the *lastest* successful execution id shows the workflow steps and relevant logs;
![](/5-app-infra/10-run-cdmc-engines/images/Workflow_ExecutionID.png)  `sample workflow`
![](/5-app-infra/10-run-cdmc-engines/images/Workflow_Sample.png) 

If errors are encountered in any of the workflow steps, navigate to `Cloud Run` -> `Services`, click on the `tag-engine-api` service, and filter the logs by `errors` under the `LOGS` tab. 
![](/5-app-infra/10-run-cdmc-engines/images/Tag_Engine_Error.png) 

In the `Data Governance` project, navigate to `Dataplex` product. In the `Filters` section on the left hand side panel, under **Projects**, select the `Non Confidential` project where the ingested data resides. Clicking on any of the source data table from the list should open up the `Data Catalog` profile for the table.

The `Data Catalog` features different sections, such as *DETAILS*, *SCHEMA*, and *LINEAGE*.

In the *DETAILS* section, the **OVERVIEW** should display three (3) of the tag engine templates applied to the table; *CDMC Controls*![](/5-app-infra/10-run-cdmc-engines/images/DataCatalog_Details_CDMC_Control.png) *Cost Metrics*, and *Impact Assessment*![](/5-app-infra//10-run-cdmc-engines/images/DataCatalog_Cost_Impact.png) respectively.

The *SCHEMA*![](/5-app-infra/10-run-cdmc-engines/images/DataCatalog_Schema.png) section displays tag engine templates applied that are column specific. It displays templates like *Correctness*, *Completeness*, *Data Sensitivity*, and *Security Policy* as per defined in the configs for each column in the table. If the column has been identified as `sensitive`, an appropriate policy tag will be applied to the column.

The *LINEAGE*![](/5-app-infra/10-run-cdmc-engines/images/DataCatalog_Lineage.png) section displays the graphical representation of how the source data is utlized downstream for validation and data quality checks.

## Validate Record Manager Output
After the `Record Manager` engine is executed, to ensure the job executed successfully, in the GCP console, navigate to `Cloud Run`. Under the `JOBS`![](/5-app-infra/10-run-cdmc-engines/images/DQ_Scanning_RecordManager.png) tab, it should list and show `Succeeded` status for the record-manager job.

The Record Manager workflow automates the purging and archiving of BQ tables to Google Cloud Storage. The service takes as input a set of BQ tables that are tagged with a data retention policy. It reads the *tags*![](/5-app-infra/10-run-cdmc-engines/images/RecordManager_Retention.png) from Data Catalog and executes the policies specified in the tags.

The purging procedure includes setting the expiration date on a table and creating a snapshot table. During the soft-deletion period, the table can be recovered from the snapshot table. After the soft-deletion period has passed, the snapshot table also gets purged and the source table can no longer be recovered.

The archival procedure includes creating an external table for each BQ table that has exceeded its retention period. The external table is stored on GCS in parquet format and upgraded to Biglake. This allows the external table to have the same column-level access as the source table. Record Manager uses Tag Engine to copy the metadata tags and policy tags from the source table to the external table. The source table is dropped once it has been archived.

## Dashboard
We have published our dashboard externally which allows other users to duplicate it in their own accounts. Once copied, the links will need to be updated to use your own data sources.

1. Request access to the Looker Studio sample CDMC dashboard by emailing cdmc-dashboard-access@google.com with details of the Google Cloud identity which you will use to access. A link to the dashboard will be shared with you.

2. Once access has been granted, click on the dashboard link and from the drop down menu on the top right hand side of Looker Studio, select `Make a copy`

3. Ignore the warnings about the data sources and press `Copy report`

4. Rename the report from `Copy of CDMC Dashboard` if desired to `<My organisation> CDMC Dashboard`

### Link the new dashboard to your own BigQuery datasets
The dashboard should open in Looker Studio Edit mode. The dashboard's data sources now need to be linked to your own datasets.

1. In your browser, go to [Looker Studio](https://studio.looker.com/)

2. From the Looker Studio `Resources` menu select `Manage added data sources`![](/5-app-infra/10-run-cdmc-engines/images/cdmc_report_add_data_sources.png)
3. Starting at the top of the list, under `NAMES`, select and copy (right click copy) the table name and click the corresponding `EDIT` action against the first datasource.![](/5-app-infra/10-run-cdmc-engines/images/cdmc_report_edit.png)  
4. Select your `data governance` project from the `My Projects` list. This should populate all the datasets under the governance project. The dashboard report uses tables from two distinct datasets, `cdmc_report_[ENV]` and the `tag_exports` respectively (See list of tables at the bottom of this page).
Select one of the two datasets, which should pop-up a table lookup section. Paste the copied table name in the `Table` search field. If the table exists in the dataset, select the table.
![](/5-app-infra/10-run-cdmc-engines/images/cdmc_report_table_select.png) 
If it does not exist in the selected dataset, search the other dataset for this table.
5. Press the `Reconnect` button on the top right corner, and `Apply` the connection changes when prompted. Press `Done`. This should take you back to the datasource list.
6. Repeat steps 2 and 3 for all the other tables from the list using the `EDIT` feature![](/5-app-infra/10-run-cdmc-engines/images/cdmc_report_edit). 
(If the INFORMATION_SCHEMA view creation failed in the earlier step, you will not be able to do this for the `information_schema_view` data source used by the Purpose Tracking report)
7. Press `Close` in the top right panel of the data sources view
8. To ensure the right project and datasets are relected on the tiles, while in the edit mode, follow steps below;
    - Click on the broken tile
    - Click pencil to edit the filter
    - In the right hand `SETUP` menu, scroll down to add filter
    - Edit string to match the project and dataset scanned
  
  Do this for both sets of 3 tiles for the 2 active datasets we scanned.
    ![](/5-app-infra/10-run-cdmc-engines/images/project_tile_edit.png) 
    ![](/5-app-infra/10-run-cdmc-engines/images/dataset_tile_edit.png)

9. Press `View` to see your new dashboard.

| tag_exports tables                         |   cdmc_report_[ENV] tables            |
|--------------------------------------------|---------------------------------------|
| catalog_report_table_ia_report             |   _information_schema_view            |
|catalog_report_column_security_report       |   _last_run_findings_summary          |
|catalog_report_table_retention_report       |   _last_run_findings_summary_alldata  |
|catalog_report_column_security_report       |   _last_run_metadata                  |
|catalog_report_table_tags                   |   _last_run_dataset_stats             |
|catalog_report_table_cdmc_controls_heatmap  |   _last_run_findings_detail           |
|catalog_report_table_cost_report            |   _last_run_dataset_stats             |
|catalog_report_column_dq_report             |                                       |
|catalog_report_table_security_report        |                                       |
|catalog_report_column_tags                  |                                       |