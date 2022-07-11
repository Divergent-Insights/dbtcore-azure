# dbt on Azure

## Overview

This project provides an end-to-end, enterprise-ready, scalable and robust implementation of dbt on Azure

![dbt + Azure + Terraform](dbt-azure-terraform.png)

The solution realized by this project is characterized by the following:

- Fully based on Microsoft Azure
- Fully automated. The solution follows the paradigm of "Everything as Code" where all code is validated and delivered automatically via CI/CD
- Uses a [monorepo](https://en.wikipedia.org/wiki/Monorepo#:~:text=In%20version%20control%20systems%2C%20a,stored%20in%20the%20same%20repository.) where infranstructure (Terraform) code and data transformation code (dbt) are elegantly defined and deployed from one repository
- dbt runs are scheduled via either Azure DevOps Pipelines (ADO) or Azure Container Instance (ACI)
- dbt database backed is Microsoft Synapse with Dedicated Pools
- Code automataion (CI/CD) is realized with Azure DevOps Pipelines (ADO Pipelines)
- All infrastructured is deployed programmatically (via Terraform)

## Use Cases

Consider this solution for:
- Using dbt as a transformation tool in medium and large organizations that are strategically alinged to Microsoft products
- Organizations with limited capacity or expertise using dbt on Azure and want to levarage existing blueprints with embeded best practices to get up and running with dbt on Azure in no time
- Organizations that value solutions that follow end-to-end DevOps practices such as version control, code review, continuous integration and continouous deployment

## Architecture

![dbt on Azure High Level Architecture Diagram](dbt-on-azure.png)

## Workflow

These are the different development workflows supported by the solution:

### Data Transformations (dbt)

1. A developer implements data transformations using dbt models
2. dbt models, which are made of SQL and Jinja, are version controlled using Azure DevOps Repos or GitHub
3. Continuous integration triggers code linting using SQLFluff and testing using dbt's integration testing best practices
4. Continuous deployment within Azure Pipelines triggers an automated deployment of dbt transformation models to a specific environment
5. dbt models are deployed to the configured database backend: Azure Synapse with Dedicated Pools
6. dbt models are scheduled via various methods such Azure Pipelines, Azure Functions, Azure Container Instance, and others
7. dbt transformations are monitored

### Infrastructure (Terraform)

1. A developer defines all required infrastructure as code via Terraform
2. Infrastructure changes are version controlled using Azure DevOps Repos or GitHub
3. Continuous integration triggers code formatting, validation, planning and deployment
4. Continuous deployment within Azure Pipelines triggers an automated deployment of infrastructure code to a specific environment5.
5. Infrastructure is fully deployed to relevant environments: non-production or production
6. Infrastrcuture is fully destroyed/updated from relevant environment: non-production or production

## Key Components

- **Version Control** - Git, GitHub or Azure Repos
- **dbt Scheduling 1** - Azure Pipelines or GitHub Actions
- **dbt Scheudling 2** - Azure Container Instance, dbt image, Azure Data Factory
- **Infrastructure** - Azure Groups, Key Vault, Azure Data Factory, Azure Container Registry / Container Instance

## Alternatives

### Version Control

- Azure DevOps Repos
- GitHub

### dbt Scheduling

- Basic Scheduling: Scheduled Azure DevOps Pipelines
- Basic Scheduling: Scheduled Azure Container Instances
- Advanced Scheduling: Self-hosted scheduler such as Airflow or Dagster
- Advanced Scheduling: Managed scheduler such as Airflow, Dagster or Prefect

## Considerations

### Security

- All credentials are generated automatically and fetched safely programmatically via Azure Key Vault
- Where possible Azure Managed Identities or Azure Service Principals are prioritized and utilized

### Costs

- Automated restart/pause of Azure Synapse Dedicated Pools can easily be realized via Azure Pipelines or Azure Data Factory
- dbt Scheduling Costs: Azure Pipelines vs Azure Data Factory + Azure Container Instance

## Additional Enhancements

- Sending all logs to centralized logging repository such as Azure Monitor (simple)
- Dynamic extraction of Azure Key Vault values from all automation scripts

## Copyright

© 2022 Divergent Insights Pty Ltd - <info@divergentinsights.com.au>