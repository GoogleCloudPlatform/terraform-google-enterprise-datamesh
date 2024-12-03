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

# Adding an Additional Data Domain

This section will guide you through the process of adding an additional data domain to your data mesh.

## 4-Projects

Creating a new data domain requires a new set of repositories to be created.  Each data domain you build will be unique with it's own set of processes and deployments.

1. In `shared.auto.tfvars`, there is a variable that needs attention: `gh_common_project_repos`.  This object needs to be updated with the new repositories for your data domain, along with a consumer project for your data domain.  The following repositories will be needed:
    - ingestion
    - non-confidential
    - confidential
    - consumer

    For example, lets assume you want a new data domain named `domain-2`.  You will need to add the following entries to the `gh_common_project_repos` object:

    ```
    gh_common_project_repos = {
        ...
        project_repos = {
            [...]
            domain-2-ingest         = "gcp-dm-bu4-prj-domain-2-ingest",
            domain-2-non-conf       = "gcp-dm-bu4-prj-domain-2-non-conf",
            domain-2-conf           = "gcp-dm-bu4-prj-domain-2-conf",
            domain-2-consumer       = "gcp-dm-bu4-prj-domain-2-consumer",
        }
    }
    ```
    This will create the necessary repositories for you expand on your projects for your new data domain.

2. There are 3 files that need attention: in each `main.tf` file under `business_unit_4/development`, `business_unit_4/nonproduction`, and `business_unit_4/production`, there are modules that are calling the `data_mesh` module.  The `data_mesh` module is responsible for creating the data domain structure for your environments.  To add in another data domain, two variables for this module need attention: `consumers_projects` and `data_domains`.  The format for both of these variables is as follows:

    ```
    consumers_projects = [
        {
            name = string // The name of the consumer project
            apis = optional(list(string), []) // Additional APIs that will be added to the consumer project
        }
    ]

    data_domains = [
        {
            name = string // The name of the data domain
            ingestion_apis = optional(list(string), []) // Additional APIs that will be added to the ingestion project
            non-confidential_apis = optional(list(string), []) // Additional APIs that will be added to the non-confidential project
            confidential_apis = optional(list(string), []) // Additional APIs that will be added to the confidential project
        }
    ]
    ```
    For example, lets assume you want a new data domain named `domain-2`.  You will need to add the following entries to the `consumers_projects` and `data_domains` objects:

    ```
    consumers_projects = [
        {...}
        {
            name = "consumer-2"
        }
    ]

    data_domains = [
        {..}
        {
            name = "domain-2",
        }
    ]
    ```

1. Once completed, push your chages to your `plan` branch and submit a PR to merge from `plan` to `development`. Once the terraform plan is successful, merge to `development`, then merge from `development` to `nonproduction` and finally merge from `nonproduction` to `production`.

## Artifact Publish
The artifacts project is one of the common projects, that is shared between different environments and domains. All the dataflow ingestion flex templates and images are stored under this project, that can be used across different domains, across different environments. Users can create custom or generic dataflow pipelines and store them under this project. 

As an example, users can create a generic pipeline template, that processes a file from storage bucket and loads to BQ table; this pipeline can be used by different domains. 

A domain specific, tailored pipeline template, will also reside in this same project; but then will be impletemented only for a particular domain. 

The user is responsible to ensure which templates are generic and which ones are tailored for domains. *A suggestion would, be to name the pipeline templates accordingly, as well as document their usage.*

*NOTE:* Similar to the artifact project, the governance project is a common project shared across different environments. Therefore, downstream configurations and processing of data for different domains would also be housed together. For example, `cdmc_data_quality` configuration files for all domains would be housed under the same directory [here](/5-app-infra/3-artifact-publish/docker/cdmc/cdmc_data_quality/configs/).

## 3-Networks
Your new data domain projects (ingestion, non-confidential and confidential) will be set in a service perimeter dependant on the environment (`development`, `nonproduction`, `production`).  You will need to add in egress rules to allow data to flow between your environments service perimeter and data governance.

1. In `common.auto.tfvars`, there is a variable that will need attention: `common.auto.tfvars`.  This variable needs to be updated with your new data domain's service accounts.
Notably,
    - data domain ingest terraform service account
    - data domain confidential terraform service account
    - data domain non-confidential terraform service account
    - development data flow controller service account (ingestion project)
    - nonproduction data flow controller service account (ingestion project)
    - production data flow controller service account (ingestion project)
    - development data flow controller re-identification service account (confidential project)
    - nonproduction data flow controller re-identification service account (confidential project)
    - production data flow controller re-identification service account (confidential project)
    - development non-confidential compute service account (non-confidential project) (used for interactive environment)
    - development project service account (ingestion project) (used for interactive environment
    - development pubsub writer service account (ingestion project) (used for interactive environment)
    - development project service account (non-confidential project) (used for interactive environment)

1. In `development.auto.tfvars` you will need to add in the following:

    Under `ingress_policies`, the following project numbers will need to be added to the `.to.resources` list:
     - development data domain confidential project number
     - development data domain non-confidential project number
     - development data domain ingestion project number

     Under `egress_policies`, there are several areas that will need to be filled. Under the `// kms` header, `.from.identities` will need:
     - development dataflow controller sa (ingestion project)
     - development gs service agent account (ingestion project)
     - development compute service agent account (ingestion project)
     - development dataflow service agent account (ingestion project)
     - development pubsub service agent account (ingestion project)
     - development bq default service agent account (non-confidential project)
     - development dataflow controller re-identification sa (confidential project)
     - development bq default service agent account (confidential project)
     - development gs service agent account (confidential project)
     - development dataflow service agent account (confidential project)
     - development default compute service agent account (confidential project)

     Under the `// Bigquery Data Catalog` header, `.from.identities` will need:
     - data domain confidential terraform service account
     - data domain non-confidential terraform service account
     - development dataflow controller re-identification sa (confidential project)

     Under `// Artifacts Registry` header, `.from.identities` will need:
     - data domain ingest terraform service account
     - data domain confidential terraform service account
     - development dataflow controller sa (ingestion project)
     - development data flow controller re-identification sa (confidential project)

    Under `// Secrets` header, `.from.identities` will need:
     - development dataflow controller service account (ingestion project)

    Under `// DLP` header, `.from.identities` will need:
     - development dataflow controller re-identification sa (confidential project)
     - development dataflow controller sa (ingestion project)

    Under ``// Logging` header, `.from.identities` will need:
     - data domain confidential terraform service account
     - data domain ingest terraform service account

    Under ``// Interactive Ingestion Project` header, `.from.identities` will need:
     - development gs service agent account (ingestion project)
     - development data domain project service account (ingestion project)
     - development data domain non-confidential project service account (non-confidential project)

    Under ``// Consumer Project` header, `.to.resources` will need:
     - development data domain consumer project number

    Under ``// non-confidential service catalog (cloud build) header, `.from.identities` will need:
     - development cloudbuild service agent account (non-confidential project)
     - development default compute service agent account (non-confidential project)


1. In `nonproduction.auto.tfvars` and `production.auto.tfvars`.  These two files are structured the same as each other, so you will need use the correct project numbers and project ids depending on which file you are working with.  You will need to add in the following:

    Under `ingress_policies`, the following project numbers will need to be added to the `.to.resources` list:
     - nonproduction/production data domain confidential project number
     - nonproduction/production data domain non-confidential project number
     - nonproduction/production data domain ingestion project number

    Under `egress_policies`, there are several areas that will need to be filled. Under the `// kms` header, `.from.identities` will need:
     - nonproduction/production dataflow controller sa (ingestion project)
     - nonproduction/production gs service agent account (ingestion project)
     - nonproduction/production compute service agent account (ingestion project)
     - nonproduction/production dataflow service agent account (ingestion project)
     - nonproduction/production pubsub service agent account (ingestion project)
     - nonproduction/production bq default service agent account (non-confidential project)
     - nonproduction/production dataflow controller re-identification sa (confidential project)
     - nonproduction/production bq default service agent account (confidential project)
     - nonproduction/production gs service agent account (confidential project)
     - nonproduction/production dataflow service agent account (confidential project)
     - nonproduction/production default compute service agent account (confidential project)

    Under the `// Bigquery Data Catalog` header, `.from.identities` will need:
     - data domain confidential terraform service account
     - data domain non-confidential terraform service account
     - nonproduction/production data domain dataflow controller re-identification service account (confidential project)

    Under `// Artifacts Registry` header, `.from.identities` will need:
     - data domain ingest terraform service account
     - data domain confidential terraform service account
     - nonproduction/production dataflow controller sa (ingestion project)
     - nonproduction/production data flow controller re-identification sa (confidential project)

    Under `// Secrets` header, `.from.identities` will need:
     - nonproduction/production dataflow controller service account (ingestion project)

    Under `// DLP` header, `.from.identities` will need:
     - nonproduction/production dataflow controller re-identification sa (confidential project)
     - nonproduction/production dataflow controller sa (ingestion project)

    Under `// Logging` header, `.from.identities` will need:
     - data domain confidential terraform service account
     - data domain ingest terraform service account

    Under `// Consumer Project data access` header, `.to.resources` will need:
     - nonproduction/production data domain consumer project number

1. As reference, the files mentioned above have a template that was used in [0-vpc-sc](../0-vpc-sc/README.md), under the files `shared.auto.tfvars`, `development.auto.tfvars`, `nonproduction.auto.tfvars` and `production.auto.tfvars` located within the `environments` directory.  Those files contain quotes with the project numbers and service accounts that are needed to allow data to flow between the different environments.

    It can be used as a starting point for your new data domain to ensure you are following the correct process.

1. Once completed, you will need to apply your terraform code.  Starting from your `plan` branch, you will need to submit a PR from `plan` to `development`, then merge to `development`, then merge from `development` to `nonproduction` and finally merge from `nonproduction` to `production`.

### Data Ingestion, Non-Confidential and Confidential Projects

1. Each data domain is distinct, with its own set of processes and deployments. The examples provided in the deployment of `domain-1` illustrate how the three projects are structured and operate. Depending on the requirements, adjustments may be necessary to the ingestion process, such as configuring it to ingest data exclusively from a bucket or incorporating alternative processes that suits business requirements.

    It is recommended to use the previously created domain-1 projects as a foundational template for building your new data domain. The existing codebase can either be reused as-is or modified to suit the specific needs of your domain.

    If for example, you would want to replicate the same repositories from the `domain-1` examples for your new data domain, the changes that are needed are simply changing the `domain_name` variables in each repositories `common.auto.tfvars`.  There are other adjustments that will also be needed to add in your own datasets and tables, which are documented below.

# Adding Additional Datasets To An Existing Data Domain

Now that `domain-1` has been ingested and processed by `data-governance`, you may want to add your own additional datasets and data. Or, you have created a new data domain and want to add datasets and tables to it.

For the purposes of this example, we will be adding data to the `domain-1` data domain.  If you have created a new data domain, the instructions documented below will need to be adjusted to account for your new data domain name.  It is a matter of replacing the `domain-1` references with your new data domain name and targeting your new data domain repositories for code additions.

It is important that before you begin, you know what the **name** of the datasets will be, along with the **schema** for every table you will be adding to the datasets.

The following instructions will help you do this.

## Artifact Publish
1. Starting in `bu4-artifact-publish`, under `docker/cdmc/cdmc_data_quality/configs`, you will currently find files `NewCust.yml`, `UpdCust.yml`, `cc_data.yml` and `common.yml`. Note how common rules are in the `common.yml` file and there is a config file per entity of the datasets, containing fields and rules bindings.
You can customize the configurations to your requirements. [Here](https://cloud.google.com/dataplex/docs/check-data-quality#example-specification-files) are some official google documented examples for creating these yaml files.

## Data Governance
1. In `bu4-data-governance`, under `common.auto.tfvars` there are two variables that need attention; `deidentify_field_transformations` and `dlp_job_inspect_datasets`.
    - `deidentify_field_transformations` is a list of the fields that will be de-identified. This list is used in the `de-identification` module.  You will need to _add_ the fields in your datasets tables that you want to de-identify to this list.

        For example, lets assume that you wish to have the field `customer_id` de-identified.  You will need to add the following entry to the `deidentify_field_transformations` list:

        ```
        deidentify_field_transformations = [
            ...,
            "customer_id"
        ]
        ```
    - `dlp_job_inspect_datasets` is a list of the datasets that will be scanned by the Data Loss Prevention (DLP) module.  This list is also used to configure the tag engine to build workflows for your dataset, the Scanning & Data quality engine to scan your dataset (see step 1), create DDL Tables for the report engine to reference and create DLP Job triggers.  You will need to _add_ the datasets that you want to scan to this list.
        Each object entry in this list should have the following fields:

        ```
        dlp_job_inspect_datasets = [
            {...}
            {
            environment   = string,  // The operational environment the dataset resides in
            domain_name   = string, // The name of your data-domain (eg. domain-1)
            business_code = string, // The business code for the dataset
            owner_information = object({
                name               = string // The name of the datasets owner
                email              = string / The dataset owner's email
                is_sensitive       = bool // Whether the dataset contains sensitive data
                sensitive_category = string // The sensitive category of the dataset
                is_authoritative   = bool  // Whether the dataset is authoritative
            })
            inspection_dataset        = string, // The dataset name in your non-confidential project that will be scanned
            resulting_dataset         = string, // The DLP report dataset name which will reside in the data-governance project
            inspecting_table_ids      = list(string) // The tables in the non_confidential projects dataset that will be scanned
            inspect_config_info_types = list(string) // The information types that will be scanned by the DLP job
            }
        ]
        ```

1. When you have added the information above, you will need to apply your terraform code in your `production` branch by first submitting a PR to `plan` and then merging to `production`.  This process will set data governance up with all the required information it needs to scan and report on your data.  Only after you complete the following steps should you proceed with running the engines.

## Non Confidential Project
1. In `bu4-prj-domain-1-non-conf` under `envs/nonproduction/main.tf` and `envs/production/main.tf` there is a local variable that needs attention; `dataset_ids`.  This is a list of the datasets that will be created and used by dataflex to ingest your data.  There is no need to create tables or schemas here, as the dataflex pipelines will do this for you.  The format that terraform will use for creating the dataset is as follows:  `[business_unit_code]_non_confidential_[dataset-name]_[environment]`.  You will need to _add_ the datasets that you want to add to this list.  For example, to add in a new dataset 'sales', add the string to the `dataset_ids` under locals:

    ```
    dataset_ids = [
        "dataset",
        "crm",
        "sales",
    ]
    ```
    This will create the following datasets:

    ```
    bu4_non_confidential_dataset_nonproduction
    bu4_non_confidential_crm_nonproduction
    bu4_non_confidential_sales_nonproduction
    ```

## Ingest Project
1. In `bu4-prj-domain-1-ingest` under `common.auto.tfvars` there is a variable that needs attention: `non_confidential_datasets`.  This list will contain a map of the datasets you have created along with their table names and schema.  At this point, it is necessary to know the schema of your table.  The format for the object is:
    ```
    {
        name          = string // The name of the dataset
        tables_schema = map(string) // A map of the table names and their schema. The key is the name of the table to be created and the value is the schema for the table.
        pubsub_off    = optional(bool, false) // Whether to create a pubsub topic for the dataset
        tables_file_names = map(string) // A map of the table names the encrypted csv files that will be used during ingestion.  These files exist in a bucket. Already created in `4-projects`..
    }
    ```
    The schema must be in the form of a comma separated string in the following format:

    ```
    column_name:data_type,column_name:data_type,column_name: data_type, etc
    ```

    For example, lets assume you have the following tables (orders and products) for a new dataset `sales`:
    1. **`orders`**
        - **`order_id`**: Unique identifier for the order (*String*).
        - **`customer_id`**: Identifier for the customer who placed the order (*String*).
        - **`order_date`**: Date when the order was placed (*Date*).
        - **`total_amount`**: Total amount for the order (*Float*).
    2. **`products`**
        - **`product_id`**: Unique identifier for the product (*String*).
        - **`product_name`**: Name of the product (*String*).
        - **`price`**: Price of the product (*Float*).

    Let us also assume you have encrypted the csv files for each of these tables in a bucket.  The names can be as unique as you wish, however for consistency they should have a nomenclature similar to what the the table name is:

    1. orders.csv
    2. products.csv

    The resulting format for your new object would be:

    ```
    non_confidential_datasets = [
        {...}
        {
            name          = "sales"
            tables_schema = {
                orders = "order_id:string,customer_id:string,order_date:date,total_amount:float"
                products = "product_id:string,product_name:string,price:float"
            }
            tables_file_names = {
                orders = "orders.csv"
                products = "products.csv"
            }
        }
    ]
    ```
1. Before applying your terraform code, it is necessary to first encrypt your csv files and upload them into a bucket, if not already done.  The instructions for encrypting your csv files are located in [this README](../8-data-domain-1-ingest/README.md#ingesting-data-into-gcs---encrypting-and-uploading)

1. Once your csv files have been encrypted and uploaded into a bucket, you can then apply your terraform code.  Submit a PR from `plan` to `nonproduction` and then merge to `nonproduction` to apply the code and execute the dataflex pipelines.

## Confidential Project
1. In `bu4-prj-domain-1-conf` under `common.auto.tfvars` in the root of the repository, there is one variable that needs attention: `confidential_datasets`.  This list will contain a map of the datasets you have created along with their table names and schema.  At this point, it is necessary to know the schema of your table.  The format for the object is:

    ```
    {
        name          = string // The name of the dataset
        tables_schema = map(string) // A map of the table names and their schema. The key is the name of the table to be created and the value is the schema for the table.
    }
    ```

    The schema must be in the form of a comma separated string in the following format:

    ```
    column_name:data_type,column_name:data_type,column_name: data_type, etc
    ```

    For example, lets assume you have the following tables (orders and products) for a new dataset `sales`:

   1. **`orders`**
        - **`order_id`**: Unique identifier for the order (*String*).
        - **`customer_id`**: Identifier for the customer who placed the order (*String*).
        - **`order_date`**: Date when the order was placed (*Date*).
        - **`total_amount`**: Total amount for the order (*Float*).
    2. **`products`**
        - **`product_id`**: Unique identifier for the product (*String*).
        - **`product_name`**: Name of the product (*String*).
        - **`price`**: Price of the product (*Float*).

    You will need to _add_ the new dataset(s) that you want to add to this list.  For example, to add in a new dataset 'sales' with its tables and schema, add the following object to the `confidential_datasets` under locals:

    ```
    confidential_datasets = [
        {...}
        {
            name          = "sales"
            tables_schema = {
                orders   = "order_id:STRING,customer_id:STRING,order_date:DATE,total_amount:FLOAT"
                products = "product_id:STRING,product_name:STRING,price:FLOAT"
            }
        }
    ]
    ```
1. Once completed, you will need to apply your terraform code in your `nonproduction` branch by first submitting a PR from `plan` to `nonproduction` and then merging to `nonproduction`.
