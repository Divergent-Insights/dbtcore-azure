# dbt on Azure

## Overview

This project is an enterprise-ready, scalable and robust end-to-end implementation of dbt on Azure:

- This solution is fully based on Microsoft Azure
- This is a monorepository solution: infranstructure (Terraform) and data transformation changes (dbt) are orchestrated in one repository
- All infrastructured is deployed programmatically (via Terraform)
- Code automataion (CI/CD) is realized with Azure DevOps Pipelines (ADO Pipelines)
- dbt runs are scheduled via either ADO or Azure Container Instance (ACI)
- dbt database backed is Microsoft Synapse with Dedicated Pools

## Use Cases

Consider this solution for:
- Using dbt as a transformation tool in medium and large organizations that are strategically alinged to Microsoft products
- Organization that want to get up and running with dbt on Azure and have limited capacity or expertise setting up these new tools
- Organizations that value DevOps practices such as version control, code review, continuous integration and continouous deployment

## Architecture

## Workflow

These are the different development workflows supported by the solution:

### Data Transformations (dbt)

1. A developer changes application source code.
2. Application code including the web.config file is committed to the source code repository in Azure Repos.
3. Continuous integration triggers application build and unit tests using Azure Test Plans.
4. Continuous deployment within Azure Pipelines triggers an automated deployment of application artifacts with environment-specific configuration values.
5. The artifacts are deployed to Azure App Service.
6. Azure Application Insights collects and analyzes health, performance, and usage data.
7. Developers monitor and manage health, performance, and usage information.
8. Backlog information is used to prioritize new features and bug fixes using Azure Boards.

### Infrastructure (Terraform)

1. A developer changes application source code.
2. Application code including the web.config file is committed to the source code repository in Azure Repos.
3. Continuous integration triggers application build and unit tests using Azure Test Plans.
4. Continuous deployment within Azure Pipelines triggers an automated deployment of application artifacts with environment-specific configuration values.
5. The artifacts are deployed to Azure App Service.
6. Azure Application Insights collects and analyzes health, performance, and usage data.
7. Developers monitor and manage health, performance, and usage information.
8. Backlog information is used to prioritize new features and bug fixes using Azure Boards.

## Key Components

- **Version Control** asdf adf
- **dbt Scheduling 1** dff ads
- **dbt Scheudling 2** asdf ad
- **Infrastructure** dfasdf

## Alternatives

### Version Control

adfasdfadfadfa

### dbt Scheduling

adadfadfadfadfad

## Considerations

### Security

- One
- Two

### Costs

- One
- Two

## Deploying this solution

### Prerequisites

### Walk-through

## Copyright

© 2022 Divergent Insights Pty Ltd - <info@divergentinsights.com.au>