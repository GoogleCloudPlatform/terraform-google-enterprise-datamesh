# Data-Mesh

This documentation describes the process to configure and deploy Data Mesh into your organization.
For the purposes of this guide, it is suggested to keep all default values in place to allow for a smoother and consistent experience.

This guide assumes you have already configured and deployed the [Foundations Project Version 4.1](https://github.com/terraform-google-modules/terraform-example-foundation/tree/v4.1.0).

Data Mesh has been developed with GitHub and Cloudbuild connections, and will assume your foundations follows this same process.

At the time of this writing, foundations does not have support for gitHub and Cloudbuild connections, so a customized module is provided for this example.

If you have not deployed foundations, refer to [`0-bootstrap/README-GitHub.md`](https://github.com/terraform-google-modules/terraform-example-foundation/blob/v4.1.0/0-bootstrap/README-GitHub.md) in the official repository.
It contains the necessary steps and procedures that are needed to deploy Foundations from scratch.

Once successfully deployed, you can begin the deployment process for Data Mesh, starting from `Dependencies` and working your way in sequence.  This includes the necessary additions to the foundations project which are needed to deploy Data Mesh.

## Dependencies

### IAM

You must have role **Service Account User** (`roles/iam.serviceAccountUser`) on the [Terraform Service Account](https://github.com/terraform-google-modules/terraform-example-foundation/blob/master/docs/GLOSSARY.md#terraform-service-account) created in the foundation [Seed Project](https://github.com/terraform-google-modules/terraform-example-foundation/blob/master/docs/GLOSSARY.md#seed-project).
  The Terraform Service Account has the permissions to deploy step 4-projects of the foundation:
  - `sa-terraform-proj@<SEED_PROJECT_ID>.iam.gserviceaccount.com`

### Software

Install the following dependencies:

- [Google Cloud SDK](https://cloud.google.com/sdk/install) version 400.0.0 or later.
- [Terraform](https://www.terraform.io/downloads.html) version 1.5.7 or later.

- [Tinkey](https://developers.google.com/tink/tinkey-overview) version 1.11.0 or later
- [Java](https://openjdk.org/install/) version 11 or later

- [jq](https://stedolan.github.io/jq/) version 1.6 or later

### Cloud SDK configurations

To configured **Application Default Credentials** run:

```bash
gcloud auth application-default login
```

### Directory layout and Terraform initialization

For these instructions we assume that:

- The foundation was deployed using GitHub Actions.
- Every repository should be on the `plan` branch and `terraform init` should be executed in each one.
- The following layout should exists in your local environment since you will need to make changes in these steps.
If you do not have this layout, checkout the source repositories for the foundation steps following this layout.

  ```text
    gcp-bootstrap
    gcp-environments
    gcp-networks
    gcp-org
    gcp-projects
  ```

- Also checkout the repository for this code, `gcp-data-mesh-foundations`, at the same level.

The final layout should look as follows:

  ```
    gcp-data-mesh-foundations
    gcp-bootstrap
    gcp-environments
    gcp-networks
    gcp-org
    gcp-projects
  ```

### Update gcloud terraform vet policies

Update `serviceusage_allow_basic_apis.yaml` to include the following apis:

```
    - "firestore.googleapis.com"
    - "orgpolicy.googleapis.com"
    - "cloudtasks.googleapis.com"
    - "bigqueryconnection.googleapis.com"
    - "bigquerydatapolicy.googleapis.com"
    - "bigquerydatatransfer.googleapis.com"
    - "composer.googleapis.com"
    - "containerregistry.googleapis.com"
    - "datacatalog.googleapis.com"
    - "dataflow.googleapis.com"
    - "dataplex.googleapis.com"
    - "datalineage.googleapis.com"
    - "dlp.googleapis.com"
    - "resourcesettings.googleapis.com"
    - "dataform.googleapis.com"
    - "datapipelines.googleapis.com"
```


Update the local copies on each repository:

- `gcp-bootstrap/policy-library/policies/constraints/serviceusage_allow_basic_apis.yaml`
- `gcp-environments/policy-library/policies/constraints/serviceusage_allow_basic_apis.yaml`
- `gcp-networks/policy-library/policies/constraints/serviceusage_allow_basic_apis.yaml`
- `gcp-org/policy-library/policies/constraints/serviceusage_allow_basic_apis.yaml`
- `gcp-projects/policy-library/policies/constraints/serviceusage_allow_basic_apis.yaml`

If your policy constraints are being pulled from a different location or repository, update this file in its correct location.
Commit and push the code on any repository changed.


## 0. Bootstrap

1. Add the role **Organization Policy Administrator** (`roles/orgpolicy.policyAdmin`) to the Terraform Service account created for the `projects` step `sa-terraform-proj@<SEED_PROJECT_ID>.iam.gserviceaccount.com`. Organizational policies at a _project_ level will be needed for data mesh to function successfully.  In addition, add in the extra variables needed to deploy:

    ```bash
    cd gcp-bootstrap

    cp ../gcp-data-mesh-foundations/0-bootstrap/iam-datamesh.tf ./envs/shared/iam-datamesh.tf
    cp ../gcp-data-mesh-foundations/0-bootstrap/variables-datamesh.tf ./envs/shared/variables-datamesh.tf
    ```

1. This process will also need a [Classic](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token#creating-a-fine-grained-personal-access-token) personal access token:

    - This token will need access to create and modify repositories for project specific repositories created in step `4-projects`
        - Permissions:
            - Repositories: Full control
            - User: read:user
            - Admin(Org): read and write
            - Admin(Repo_hook): read and write
            - Admin:(Org_Hook)


1. To prevent saving the `gh_token` and `github_app_infra_token` in plain text in the `terraform.tfvars` file,
export the GitHub fine grained access token as well as the Github application infrastructure token (Classic token) as an environment variable:

   ```bash
   export TF_VAR_gh_token="YOUR-FINE-GRAINED-ACCESS-TOKEN"
   export TF_VAR_github_app_infra_token="YOUR-CLASSIC-ACCESS-TOKEN"
   ```

1. In the `github.tf` file, located in `gcp-bootstrap/envs/shared`, update the `common_secrets` local variable and include the GitHub App Infra Token:
   ```bash
   common_secrets = {
      "PROJECT_ID" : module.gh_cicd.project_id,
      "WIF_PROVIDER_NAME" : module.gh_oidc.provider_name,
      "TF_BACKEND" : module.seed_bootstrap.gcs_bucket_tfstate,
      "TF_VAR_gh_token" : var.gh_token,
      "TF_VAR_github_app_infra_token" : var.github_app_infra_token,
    }
   ```

1. Update the GitHub workflow files with the latest versions required for the Data Mesh setup. Please note that the `github-*.yaml` files differ slightly from those in [Foundations Project Version 4.1](https://github.com/terraform-google-modules/terraform-example-foundation/tree/v4.1.0). In these files, an additional `env` variable has been added to enable access to a GitHub secret: `"TF_VAR_github_app_infra_token"`. This classic token, which will be propagated to your current GitHub Foundation repositories, will be essential in future steps for creating repositories as you progress to the `4-projects` stage.

   For this Data Mesh example foundation, it is recommended to retain this configuration to facilitate a smoother deployment process.


    ```bash
    cp ../gcp-data-mesh-foundations/build/github-*.yaml ./.github/workflows
    ```
1. Run this process manually to ensure that the `TF_VAR_gh_token` and `TF_VAR_github_app_infra_token` are not set in the `terraform.tfvars` file.

    ```bash
    cd envs/shared
    git checkout plan

    terraform init
    terraform plan -input=false -out bootstrap.tfplan
    ```
1. Once terraform plan has finished, review the output and apply the changes.

    ```bash
      terraform apply bootstrap.tfplan
    ```

1. Push your changes to your `gcp-bootstrap` repository.

    ```bash
    cd ../..
    git add .
    git commit -m 'add required data-mesh iam role'
    git push
    ```

1. Submit a PR in `gcp-bootstrap` from `plan` to `production`.  This will trigger a terraform plan.  Allow the plan to complete.  Once complete, merge the PR to `production`.  This action will not change your state file, however it will ensure that your codebase is up to date.

1. Change directory out of this folder.

    ```bash
    cd ../../../
    ```
1. Proceed to the next step `1-org`.

## 1. Org

This step creates a secret to hold the Github Token that will be used in step `5-app-infra`.

1. Copy over the following files to your `envs/shared` folder in your `gcp-org` repository or `1-org` folder:

    - gcp-data-mesh-foundations/1-org/envs/shared/iam-datamesh.tf
    - gcp-data-mesh-foundations/1-org/envs/shared/keys-datamesh.tf
    - gcp-data-mesh-foundations/1-org/envs/shared/outputs-datamesh.tf
    - gcp-data-mesh-foundations/1-org/envs/shared/variables-datamesh.tf
    - gcp-data-mesh-foundations/1-org/envs/shared/secrets-datamesh.tf
    - gcp-data-mesh-foundations/1-org/envs/shared/remote-datamesh.tf


    ```bash
    cd gcp-org
    git checkout plan
    ```
    ```bash
    cp ../gcp-data-mesh-foundations/1-org/envs/shared/iam-datamesh.tf ./envs/shared/iam-data-mesh.tf
    cp ../gcp-data-mesh-foundations/1-org/envs/shared/keys-datamesh.tf ./envs/shared/keys-datamesh.tf
    cp ../gcp-data-mesh-foundations/1-org/envs/shared/outputs-datamesh.tf ./envs/shared/outputs-datamesh.tf
    cp ../gcp-data-mesh-foundations/1-org/envs/shared/variables-datamesh.tf ./envs/shared/variables-datamesh.tf
    cp ../gcp-data-mesh-foundations/1-org/envs/shared/secrets-datamesh.tf ./envs/shared/secrets-datamesh.tf
    cp ../gcp-data-mesh-foundations/1-org/envs/shared/remote-datamesh.tf  ./envs/shared/remote-datamesh.tf
    ```

1. Overwrite the github workflows files with the current files needed for data-mesh.

    ```bash
    cp ../gcp-data-mesh-foundations/build/github-*.yaml ./.github/workflows
    ```

1. Add a new environment `common` in file `gcp-org/envs/shared/projects.tf` in local `environments`

    ```
      environments = {
        "development" : "d",
        "nonproduction" : "n",
        "production" : "p",
        "common" : "c"
      }
    ```

1. Push your changes to your `gcp-org` repository.
    ```bash
    git add .
    git commit -m 'add required data-mesh configuration'
    git push
    ```

1. Submit a PR from `plan` to `production`.  Allow the plan to complete.  Once complete, merge the PR to `production`.  Allow your terraform apply to complete.

1. Change directory out of this folder.

    ```bash
    cd ..
    ```

## 2. Environments

1. CD into the `gcp-environments` folder
    ```bash
    cd gcp-environments
    git checkout plan
    ```

1. Copy over the following files to your respective environment folders in your `gcp-environments` repository or `2-environments`folder:

    - envs/development/outputs-datamesh.tf
    - envs/nonproduction/outputs-datamesh.tf
    - envs/production/outputs-datamesh.tf

    ```bash
    cp ../gcp-data-mesh-foundations/2-environments/envs/development/outputs-datamesh.tf ./envs/development/outputs-datamesh.tf
    cp ../gcp-data-mesh-foundations/2-environments/envs/nonproduction/outputs-datamesh.tf ./envs/nonproduction/outputs-datamesh.tf
    cp ../gcp-data-mesh-foundations/2-environments/envs/production/outputs-datamesh.tf ./envs/production/outputs-datamesh.tf
    ```

1. Overwrite the github workflows files with the current files needed for data-mesh.

    ```bash
    cd gcp-environments
    cp ../gcp-data-mesh-foundations/build/github-*.yaml ./.github/workflows
    ```


1. Additionally, add the following files to the `modules/env_baseline` folder in your `gcp-environments` repository or `2-environments` folder.

    - kms-datamesh.tf
    - remote-datamesh.tf
    - variables-datamesh.tf
    - outputs-datamesh.tf


    ```bash
    cp ../gcp-data-mesh-foundations/2-environments/modules/env_baseline/kms-datamesh.tf ./modules/env_baseline/kms-datamesh.tf
    cp ../gcp-data-mesh-foundations/2-environments/modules/env_baseline/remote-datamesh.tf ./modules/env_baseline/remote-datamesh.tf
    cp ../gcp-data-mesh-foundations/2-environments/modules/env_baseline/variables-datamesh.tf ./modules/env_baseline/variables-datamesh.tf
    cp ../gcp-data-mesh-foundations/2-environments/modules/env_baseline/outputs-datamesh.tf ./modules/env_baseline/outputs-datamesh.tf

    git add .
    git commit -m 'add required data-mesh configuration'
    git push
    ```

1. Create a PR in `gcp-environments` from `plan` to `development`.  This will trigger a terraform plan.  Allow the plan to complete.  Once complete, merge the PR to `development`.

1. Repeat the above steps for `nonproduction`.  Create a PR from `development` to `nonproduction`.  Alow the plan to complete.  Once complete, merge the PR to `nonproduction`.

1. Repeat the above steps for `production`.  Create a PR from `nonproduction` to `production`.  Alow the plan to complete.  Once complete, merge the PR to `production`.

Wait for the build pipeline for the development branch to run successfully.
Proceed to the next step `3-networks`.

## 3. Networks - Dual Shared VPC

1. Copy over the following files from `envs/shared` to your respective environment folders in your `gcp-networks` repository or `3-networks-dual-svpc` folder.

    - envs/shared/main-datamesh.tf
    - envs/shared/outputs-datamesh.tf
    - envs/shared/variables-datamesh.tf

    ```bash
    cd gcp-networks
    git checkout plan

    cp ../gcp-data-mesh-foundations/3-networks/envs/shared/main-datamesh.tf ./envs/shared/main-datamesh.tf
    cp ../gcp-data-mesh-foundations/3-networks/envs/shared/outputs-datamesh.tf ./envs/shared/outputs-datamesh.tf
    cp ../gcp-data-mesh-foundations/3-networks/envs/shared/variables-datamesh.tf ./envs/shared/variables-datamesh.tf
    ```

1. Under `modules/restricted_shared_vpc/service_control.tf`, replace `module "regular_service_perimeter"` version from `~> 6.0` to `~> 5.2`

1. Additionally, add in the following file to `modules/restricted_shared_vpc`:
    - dns-datamesh.tf

    ```bash
    cp ../gcp-data-mesh-foundations/3-networks-dual-svpc/modules/restricted_shared_vpc/dns-datamesh.tf ./modules/restricted_shared_vpc/dns-datamesh.tf
    ```
1. If the VPC-SC perimeter has not been enforced yet, add the following line to the `modules/base_env/main.tf` file under `module "restricted_shared_vpc"`:
    ```
    enforce_vpcsc = true
    ```


1. Overwrite the github workflows files with the current files needed for data-mesh.
    ```bash
    cp ../gcp-data-mesh-foundations/build/github-*.yaml ./.github/workflows
    ```

### Additional changes

1. Under the file `shared.auto.tfvars` located in the root of `gcp-networks` repository or `3-networks-dual-svpc` folder, include the following empty lists.
  These will be filled in the following steps for `5-app-infra`

    ```
    ingress_policies = [
    ]

    egress_policies = [
    ]
    ```

1. As a _temporary_ measure, a set of egress rules will be added to `common.auto.tfvars`.  This file will be removed once step `4 Projects` is completed.  It is necessary for these rules to exist in order for the `terraform apply` commands to succeed in step `4 Projects` without encountering VPC-SC Service Perimeter errors.  In the instructions following `4 Projects`, there will be a more robust solution presented to handle VPC-SC ingress and egress rules for each environment.

    Execute the following commands:
    ```bash
    terraform -chdir="envs/shared" init
    terraform -chdir="envs/development" init
    terraform -chdir="envs/nonproduction" init
    terraform -chdir="envs/production" init
    ```

    ```bash
    terraform -chdir="../gcp-environments/envs/production" init
    terraform -chdir="../gcp-environments/envs/nonproduction" init
    terraform -chdir="../gcp-environments/envs/development" init
    ```

    ```bash
    export common_kms_project_number=$(terraform -chdir="../gcp-org/envs/shared" output -raw common_kms_project_number)
    export dev_kms_project_number=$(terraform -chdir="../gcp-environments/envs/development" output -raw env_kms_project_number)
    export nonprod_kms_project_number=$(terraform -chdir="../gcp-environments/envs/nonproduction" output -raw env_kms_project_number)
    export prod_kms_project_number=$(terraform -chdir="../gcp-environments/envs/production" output -raw env_kms_project_number)
    ```

    ```bash
    echo "common_kms_project_number = ${common_kms_project_number}"
    echo "dev_kms_project_number = ${dev_kms_project_number}"
    echo "nonprod_kms_project_number = ${nonprod_kms_project_number}"
    echo "prod_kms_project_number = ${prod_kms_project_number}"
    ```

    ```bash
    sed -i'' -e "s/COMMON_KMS_PROJECT_NUMBER/${common_kms_project_number}/" ../gcp-data-mesh-foundations/temp_vpcsc/common.auto.tfvars
    sed -i'' -e "s/DEV_KMS_PROJECT_NUMBER/${dev_kms_project_number}/" ../gcp-data-mesh-foundations/temp_vpcsc/common.auto.tfvars
    sed -i'' -e "s/NONPROD_KMS_PROJECT_NUMBER/${nonprod_kms_project_number}/" ../gcp-data-mesh-foundations/temp_vpcsc/common.auto.tfvars
    sed -i'' -e "s/PROD_KMS_PROJECT_NUMBER/${prod_kms_project_number}/" ../gcp-data-mesh-foundations/temp_vpcsc/common.auto.tfvars
    ```

    Verify that the following file has been updated:

    ```bash
    cat ../gcp-data-mesh-foundations/temp_vpcsc/common.auto.tfvars
    ```

1. Copy the `egress_policies` *variable* in the file `../gcp-data-mesh-foundations/temp_vpcsc/common.auto.tfvars` and place it in your `gcp-networks` `common.auto.tfvars` file.

`
1. After these changes are complete, push the code to the repository:

    ```bash
    git add .
    git commit -m 'add required data-mesh configuration'
    git push

    cd ..
    ```
1. Create a PR in `gcp-networks` from `plan` to `development`.  This will trigger a terraform plan.  Allow the plan to complete.  Once complete, merge the PR to `development`.

1. Repeat the above steps for `nonproduction`.  Create a PR from `development` to `nonproduction`.  Alow the plan to complete.  Once complete, merge the PR to `nonproduction`.

1. Repeat the above steps for `production`.  Create a PR from `nonproduction` to `production`.  Alow the plan to complete.  Once complete, merge the PR to `production`.


1. Once all pipelines have executed successfully, proceed to the next step `4-projects`.

## 4. Projects

If adding to an existing foundation, execute the following steps:

1. In your organization, create the following groups:

    ```
      "cdmc-conf-data-viewer@[your-domain-here]"
      "cdmc-data-viewer@[your-domain-here]"
      "cdmc-encrypted-data-viewer@[your-domain-here]"
      "cdmc-fine-grained-data-viewer@[your-domain-here]"
      "cdmc-masked-data-viewer@[your-domain-here]"
    ```

1. update your `4-projects` folder or `gcp-projects` repository with the `business_unit_4` folder.

    ```bash
    cd gcp-projects
    git checkout plan

    cp -RT ../gcp-data-mesh-foundations/4-projects/business_unit_4/ ./business_unit_4
    ```

1. Update `common.auto.tfvars` in `gcp-projects` with the groups created in Step 1.  This will be a map containing the following:

    ```bash
    cat <<EOF >> common.auto.tfvars
    consumer_groups = {
        confidential_data_viewer                  = "cdmc-conf-data-viewer@[your-domain-here]"
        non_confidential_data_viewer              = "cdmc-data-viewer@[your-domain-here]"
        non_confidential_encrypted_data_viewer    = "cdmc-encrypted-data-viewer@[your-domain-here]"
        non_confidential_fine_grained_data_viewer = "cdmc-fine-grained-data-viewer@[your-domain-here]"
        non_confidential_masked_data_viewer       = "cdmc-masked-data-viewer@[your-domain-here]"
    }
    EOF
    ```

    ```bash
    export domain_name="[your-domain-here]"

    sed -i'' -e "s/\[your-domain-here\]/${domain_name}/g" common.auto.tfvars
    ```

1. Update `development.auto.tfvars` and `nonproduction.auto.tfvars` and `production.auto.tfvars` with the creation of a variable `create_resource_locations_policy` set to `false`:

    ```bash
    echo "create_resource_locations_policy = false" >> development.auto.tfvars
    echo "create_resource_locations_policy = false" >> nonproduction.auto.tfvars
    echo "create_resource_locations_policy = false" >> production.auto.tfvars
    ```

1. Overwrite the github workflows files with the current files needed for data-mesh.

    ```bash
    cp ../gcp-data-mesh-foundations/build/github-*.yaml ./.github/workflows
    ```

1. Include the following modules located in the `modules` directory:

    - artifacts
    - data_consumer
    - data_domain
    - data_governance
    - data_mesh
    - github_cloudbuild
    - kms
    - service_catalog
    - tf_cloudbuild_workspace

    ```bash
    cp -RT ../gcp-data-mesh-foundations/4-projects/modules/artifacts/ ./modules/artifacts
    cp -RT ../gcp-data-mesh-foundations/4-projects/modules/data_consumer/ ./modules/data_consumer
    cp -RT ../gcp-data-mesh-foundations/4-projects/modules/data_domain/ ./modules/data_domain
    cp -RT ../gcp-data-mesh-foundations/4-projects/modules/data_governance/ ./modules/data_governance
    cp -RT ../gcp-data-mesh-foundations/4-projects/modules/data_mesh/ ./modules/data_mesh
    cp -RT ../gcp-data-mesh-foundations/4-projects/modules/github_cloudbuild/ ./modules/github_cloudbuild
    cp -RT ../gcp-data-mesh-foundations/4-projects/modules/kms/ ./modules/kms
    cp -RT ../gcp-data-mesh-foundations/4-projects/modules/service_catalog/ ./modules/service_catalog
    cp -RT ../gcp-data-mesh-foundations/4-projects/modules/tf_cloudbuild_workspace/ ./modules/tf_cloudbuild_workspace
    ```

1. Update each `backend.tf` file under `business_unit_4` with the bucket name of that holds your terraform states.

    ```bash
    terraform -chdir="../gcp-bootstrap/envs/shared/" init
    export backend_bucket=$(terraform -chdir="../gcp-bootstrap/envs/shared/" output -raw gcs_bucket_tfstate)
    echo "backend_bucket = ${backend_bucket}"

    for i in `find . -name 'backend.tf'`; do sed -i'' -e "s/UPDATE_ME/${backend_bucket}/" $i; done
    ```

1. This data mesh example uses GitHub with Cloud Build via Cloud Build repositories (2nd gen) connections.
You can either have terraform create your repositories, or you can create them yourself using any other available methods your organization requires.
A variable `create_repositories` is set to `true` by default in `shared.auto.tfvars`.

    To not automatically create the repositories, ensure that `create_repositories` is set to `false` in `shared.auto.tfvars` file.  For the purposes of this example, it is recommended to keep the default value of `true`.

1. In order to run this example, you will require two things:
    - A [GitHub Application Installation ID](https://github.com/apps/google-cloud-build).  The installation ID is the ID of your Cloud Build GitHub app. Your installation ID can be found in the URL of your Cloud Build GitHub App. In the following URL; (eg) https://github.com/settings/installations/1234567, the installation ID is the numerical value 1234567. Once acquired, update `shared.auto.tfvars` `github_app_installation_id` with this value.
    - A [Classic](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token#creating-a-fine-grained-personal-access-token) personal access token. This token was created in `0-bootstrap` process of this document.

1. Under `shared.auto.tfvars`, the `gh_common_project_repos` are set to create the following repositories:
    - artifacts
    - data-governance
    - ingest
    - non-confidential
    - confidential
    - consumer
    - service-catalog

1. Update your current `gcp-projects/shared.auto.tfvars` to include the following variables, replacing `update-me` with your GitHub organization name and `00000000` with your installation ID.

    ```
    github_app_installation_id = 00000000
    create_repositories = true
    gh_common_project_repos = {
      owner = "update-me",
      project_repos = {
        artifacts         = "gcp-dm-bu4-prj-artifacts",
        data-governance   = "gcp-dm-bu4-prj-data-governance",
        domain-1-ingest   = "gcp-dm-bu4-prj-domain-1-ingest",
        domain-1-non-conf = "gcp-dm-bu4-prj-domain-1-non-conf",
        domain-1-conf     = "gcp-dm-bu4-prj-domain-1-conf",
        consumer-1        = "gcp-dm-bu4-prj-consumer-1",
        service-catalog   = "gcp-dm-bu4-prj-service-catalog",
      }
    }

    gh_artifact_repos = {
      owner = "update-me",
      artifact_project_repos = {
        artifact-repo   = "gcp-dm-bu4-artifact-publish"
        service-catalog = "gcp-dm-bu4-service-catalog-solutions"
      }
    }
    ```

1. `ingest`, `non-confidential` and `confidential` are set for `domain-1` which is the placeholder data domain name for the purposes of this example.  Each additional data domain you wish to add will need to be added to the `gh_common_project_repos` object.

    To further the use of this example, the artifacts project needs a secondary repository which will hold the Dockerfiles and python packages for the data mesh to be built via pipelines.

    You will find the information for this repository under `gh_artifact_repos` in `shared.auto.tfvars`.

1. Data Domains and Consumer projects are defined in each `main.tf` file in their respective environments.  The variables are defined as:

    ```
      variable "data_domains" {
        description = "values for data domains"
        type = list(object(
          {
            name                  = string
            ingestion_apis        = optional(list(string), [])
            non-confidential_apis = optional(list(string), [])
            confidential_apis     = optional(list(string), [])
          }
        ))
      }

      variable "consumers_projects" {
      description = "values for consumers projects"
      type = list(object(
        {
          name = string
          apis = optional(list(string), [])
        }
      ))
    }
    ```
    It is advisable that you keep these defaulted for the purposes of this example.


1. Much like foundations, it is imperative that the `shared` folder is _manually_ planned and applied.
This is due to the environment deployments heavy reliance on the outputs of `shared`.
Once ready, apply your terraform code:

    ```bash
    export GOOGLE_IMPERSONATE_SERVICE_ACCOUNT=$(terraform -chdir="../gcp-bootstrap/envs/shared/" output -raw projects_step_terraform_service_account_email)

    echo ${GOOGLE_IMPERSONATE_SERVICE_ACCOUNT}
    ```
    ```bash
    export CLOUD_BUILD_PROJECT_ID=$(terraform -chdir="../gcp-bootstrap/envs/shared/" output -raw cicd_project_id)

    echo ${CLOUD_BUILD_PROJECT_ID}
    ```
    ```bash
    gcloud auth application-default login --impersonate-service-account=${GOOGLE_IMPERSONATE_SERVICE_ACCOUNT}
    ```
    ```bash
    export TF_VAR_github_app_infra_token="YOUR-CLASSIC-ACCESS-TOKEN"
    echo $TF_VAR_github_app_infra_token
    ```
    ```bash
    ./tf-wrapper.sh init shared
    ./tf-wrapper.sh plan shared

    ./tf-wrapper.sh validate shared $(pwd)/policy-library ${CLOUD_BUILD_PROJECT_ID}

    ./tf-wrapper.sh apply shared
    ```
1. Unset your impersonated service account

    ```bash
    gcloud auth application-default login
    unset GOOGLE_IMPERSONATE_SERVICE_ACCOUNT
    ```

1. Push your code to the repository
    ```bash
    git add .
    git commit -m 'add required data-mesh configuration'
    git push
    ```

1. Create a PR in `gcp-networks` from `plan` to `development`.  This will trigger a terraform plan.  Allow the plan to complete.  Once complete, merge the PR to `development`.

    \*\*N.B.:\*\* The terraform plan may take upwards of 15 mintutes to complete. It may seem that it has stalled, but due to the resources being gathered and the amount of data being processed, it will take some time.
1. Once the plan has completed successfully, Merge your PR.

1. Repeat the above steps for `nonproduction`.  Create a PR from `development` to `nonproduction`.  Alow the plan to complete.  Once complete, merge the PR to `nonproduction`.

    \*\*N.B.:\*\* The terraform plan may take upwards of 15 mintutes to complete. It may seem that it has stalled, but due to the resources being gathered and the amount of data being processed, it will take some time.

1. Repeat the above steps for `production`.  Create a PR from `nonproduction` to `production`.  Alow the plan to complete.  Once complete, merge the PR to `production`.

    \*\*N.B.:\*\* The terraform plan may take upwards of 15 mintutes to complete. It may seem that it has stalled, but due to the resources being gathered and the amount of data being processed, it will take some time.

1. In `5-app-infra/4-data-governance`, CDMC Tag engine will be deployed out.  In order for tag engine to run properly, Organization Policies must be created on the _project level_.  If the policy is created on an initial terraform apply, the validation mechanism (`gcloud terraform vet`) fails with an error: `Error converting TF resource to CAI: Invalid parent address() for an asset`.  This issue happens because the projects being targeted have not been created yet.  To resolve this, `development.auto.tfvars`, `nonproduction.auto.tfvars`, and `production.auto.tfvars` contain a variable `create_resource_locations_policy`.  These are currently set to false.  Once the steps above have been executed, set this variable to true.  This will allow the policy to be created without error, as the projects being targeted have been now created.  This will resolve the terraform validation error above.

1. Set the variable `create_resource_locations_policy` to true in `development.auto.tfvars`, `nonproduction.auto.tfvars`, and `production.auto.tfvars`.

1. Push your code to the repository
    ```bash
    git add .
    git commit -m 'add required data-mesh configuration'
    git push
    ```

1. Once you have set the valriables to true, you must run through each environment deployment again.  Start by submitting a PR from `plan` to the `development` branch.  Once that has been merged, submit a PR to the `nonproduction` branch.  Once that has been merged, submit a PR to the `production` branch.

1. Once all of the PRs have been merged and all terraform code has been applied, CD out of the folder

    ```bash
    cd ..
    ```

## 5-App-infra

Once `4-projects` has been updated and deployed, follow the instructions in each subfolder in the [`5-app-infra`](5-app-infra) folder.

Each deployment step must be done via numerical order:
- [`0-vpc-sc`](5-app-infra/0-vpc-sc) : this will offer instructions to update all service perimeters that are used in the data mesh project
- [`1-tag-engine-oauth`](5-app-infra/1-tag-engine-oauth) : this will offer instructions on configuring oauth for the tag engine
- [`2-artifacts-project`](5-app-infra/2-artifacts-project): this will offer instructions on deploying the artifacts project which will be used to configure pipelines to build docker containers
- [`3-artifact-publish`](5-app-infra/3-artifact-publish): this will offer the repository contents for publishing artifacts (Dockerfiles and python packages) to the artifacts project
- [`4-data-governance`](5-app-infra/4-data-governance): this will offer instructions on deploying the data governance project
- [`5-service-catalog-project`](5-app-infra/5-service-catalog-project): this will offer instructions on deploying the service catalog project
- [`6-service-catalog-solutions`](5-app-infra/6-service-catalog-solutions): this will offer instructions on deploying the service catalog solutions for the interactive environment.
- [`7-data-domain-1-non-confidential`](5-app-infra/7-data-domain-1-non-confidential): this will offer instructions on deploying the non-confidential data project
- [`8-data-domain-1-ingest`](5-app-infra/8-data-domain-1-ingest): this will offer instructions on deploying the data ingestion project
- [`9-data-domain-1-confidential`](5-app-infra/9-data-domain-1-confidential): this will offer instructions on deploying the confidential data project
- [`10-run-cdmc-engines`](5-app-infra/10-run-cdmc-engines): this will offer instructions on how to run the CDMC engines
- [`11-consumer-1`](5-app-infra/11-consumer-1): this will offer instructions on deploying the Consumer project
- [`12-adding-additional-data`](5-app-infra/12-adding-additional-data): this will offer instructions on how to add additional data domains and/or datasets to an existing data domain