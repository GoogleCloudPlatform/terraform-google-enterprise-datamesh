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

# Artifact Publish
Repository for artifact-repo

1. clone your repository that was created in 4-projects
   ```bash
   git clone git@github.com:[git-owner-name]/gcp-dm-bu4-artifact-publish.git bu4-artifact-publish
   ```

1. cd over to the `bu4-artifact-publish` directory
    ```bash
    cd bu4-artifact-publish
    ```

1. Seed the repository if it has not been initialized yet.

   ```bash
   git checkout -b development
   git push --set-upstream origin development

   git checkout -b production
   git push --set-upstream origin production

   git checkout -b nonproduction
   git push --set-upstream origin nonproduction

   git checkout main
   ```

1. Copy contents of foundation to new repo.

   ```bash
   cp ../gcp-data-mesh-foundations/build/cloudbuild-docker-* .
   cp ../gcp-data-mesh-foundations/build/cloudbuild-python-* .
   cp -R ../gcp-data-mesh-foundations/5-app-infra/3-artifact-publish/* .
   ```

1. Commit Changes
   ```bash
   git add .
   git commit -m 'Initialize artifacts repo'
   git push
   ```

1. Create a PR request from `main` to `development` in your GitHub Repository.  This will trigger test builds for all docker images

1. Observe the builds in GCP Build by going to: https://console.cloud.google.com/cloud-build/builds;region=us-central1?project=[prj-c-bu4-artifacts-ID-HERE]

1. Once the builds have been satisfied without error, Merge your request and view both docker builds + pushes, along with python registry additions.

   **N.B.**: The python build can take upwards to 2 hours to complete. It may seem that it has stalled, but due to the resources being gathered and the amount of data being processed, it will take some time.

1. Repeat this process by submitting another PR request from `development` to `nonproduction` and then merging. Allow the images to build, tag and push.

1. Repeat this process one last time by submitting a PR request from `nonproduction` to `production` and merging.  Allow the images to build, tag and push

1. In your browser, go to: https://console.cloud.google.com/cloud-build/builds;region=us-central1?project=[prj-c-bu4-artifacts-ID-HERE] to view the image builds.  Pay close attention to the tags that are created.  There are two per image, which distinguish between `development`, `production` and `nonproduction` and the commit hash that was used to build them.

### Image Tagging in Each Environment

Each environment’s image will have two distinct tags to support clear identification and tracking of image versions:

1. **Environment Tag**: This tag identifies the environment (`development`, `nonproduction`, or `production`) where the image is deployed, making it easy for users to identify which environment an image is intended for.

2. **Short SHA Tag**: Each image is additionally tagged with a short version of the merge commit SHA (e.g., `123abc`). This tag provides a unique identifier that corresponds to the specific commit, allowing users to trace each image back to its source code.

By using these dual tags, users can distinguish between images across environments while also benefiting from the option to choose images by their specific commit short SHA during development. This flexibility supports a streamlined development process, enabling teams to verify specific commits without ambiguity.

### Operational Use in Production

In an operational environment, this pipeline setup facilitates continuous integration and continuous deployment (CI/CD) for reliable and streamlined updates across environments:

- **Development Phase**: Changes and updates are initially built and tested in the `development` environment. Developers use this branch to ensure the code runs as expected.

- **Nonproduction Phase**: When a feature or change is ready for further testing, it is promoted to `nonproduction`. This environment serves as a staging area, allowing more comprehensive testing and user acceptance before reaching production.

- **Production Deployment**: After successful testing, changes are promoted to `production`, making them live in the operational environment. Production images are tagged with unique commit hashes, providing traceability for rollbacks or audits if necessary.

This branching strategy supports a structured progression from development to production, minimizing risks and ensuring that each build meets the quality and compliance standards before becoming operational.

1. Once done, change directory out of this folder
   ```bash
   cd ..
   ```