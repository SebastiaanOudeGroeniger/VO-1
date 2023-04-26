# cmp-data-warehouse

This repository contains the relevant code to configure and provision the Compass data warehouse.
Please review the development strategy document for detailed information on how we develop solutions within our data platform.

- The link to the development strategy document: https://tinyurl.com/5n824nh5 

## Database projects
- The root folder is set to /database-project
- The development of the database projects takes place on the development environment. 
- All environments are provisioned via the CD workflow.

## Synapse workspace
- The development Synapse workspace is connected to this Repository
- The root folder is set to /synapse-workspace
- Acceptance and production are provisioned via the CD workflow.

## CI/CD workflow
The CI/CD workflow for the database projects is as follows:
- When a feature branch is merged with the development branch, CI/CD workflow takes place via GitHub Actions. The yaml file which triggers the workflow can be found in .github/workflows. The steps involved in CI/CD of the database is as follows:
  1. Init – checks for the initialization branch [main, uat or development].
  2. The build step involves building the database projects using MSBuild. MSBuild builds the database projects using the sqldb.sln file.
  3. The release step involves deploying the dacpac files to the target databases using sql-action.
- The databases are built and released parallelly using the matrix strategy found in the workflow. Currently, the build workflow runs on windows-2019 runner and the release workflow runs on self-hosted runner. Once the deployment of the database takes place on the development, acceptance and production [uat and main respectively] follows after some additional checks/tests.


