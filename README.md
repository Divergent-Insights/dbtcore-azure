# dbt on Azure

## Overview

This project provides an end-to-end, enterprise-ready, scalable and robust implementation of dbt on Azure

![dbt + Azure + Terraform](dbt-azure-terraform.png)

The solution realized by this project is characterized by the following:

- Fully based on Microsoft Azure
- Fully automated. The solution follows the paradigm of "Everything as Code" where all code is validated and delivered automatically via CI/CD
- Uses a [monorepo](https://en.wikipedia.org/wiki/Monorepo#:~:text=In%20version%20control%20systems%2C%20a,stored%20in%20the%20same%20repository.) where infranstructure (Terraform) code and data transformation code (dbt) are defined and deployed from a single repository
- Two scheduling options: dbt runs are scheduled via either Azure DevOps Pipelines (ADO) or Azure Container Instance (ACI)
- Microsoft Synapse with Dedicated Pools is used as the data warehouse backend with dbt
- Code automataion (CI/CD) is realized with Azure DevOps Pipelines (ADO Pipelines)
- All infrastructured is deployed programmatically (via Terraform)

## Use Cases

Consider this solution when:
- Using dbt as a transformation tool in organizations that are strategically alinged to Microsoft products
- Working in organizations with limited capacity or expertise using dbt on Azure and want to levarage existing blueprints with embeded best practices to get up and running with dbt on Azure in no time
- Wokring in organizations that value solutions that follow end-to-end DevOps practices such as version control, code review, continuous integration and continouous deployment

## Architecture

![dbt on Azure High Level Architecture Diagram](dbt-on-azure.png)

## Workflow

These are the different development workflows supported by the solution: data transformations via dbt, dbt scheduling option 1, dbt scheduling option 2 and infrastructure as code deployment

### Data Transformations via dbt

1. A developer implements data transformations using dbt models (dbtproject)
2. dbt models, which are made of SQL and Jinja, are version controlled using Azure DevOps Repos or GitHub
3. Continuous integration triggers code linting using SQLFluff and testing using dbt's integration testing best practices
4. Continuous deployment within Azure Pipelines triggers an automated deployment of dbt transformation models to a specific environment
5. dbt models are deployed to the configured database backend: Azure Synapse with Dedicated Pools
6. dbt models are scheduled via various methods such Azure Pipelines, Azure Functions, Azure Container Instance, and others
7. dbt transformations are monitored

### dbt Scheduling Option 1

1. An Azure Pipeline is configured to run on a regular basis (e.g. every 1 hour)
2. The Azure Pipeline uses an image that is configured to run dbt e.g. Python, dbt profiles.yml, and dbt
3. The Azure Pipeline obtains in a safely manner all credentials required to execute dbt and connect to the relevant database backend (e.g. Synapse)
4. The Azure Pipeline executes "dbt run" and deploys any relevant changes applied to the dbt project (dbtproject)

### dbt Scheduling Option 2

1. An Azure Data Factory (ADF) Pipeline is configured to run on a regular basis (e.g. every 1 hour)
2. The ADF Pipeline uses an image that is configured to run dbt e.g. Python, dbt profiles.yml, and dbt
3. The ADF Pipeline obtains in a safely manner all credentials required to execute dbt and connect to the relevant database backend (e.g. Synapse)
4. The ADF Pipeline executes "dbt run" and deploys any relevant changes applied to the dbt project (dbtproject)

### Infrastructure as Code via Terraform

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
- Advanced Scheduling: Managed scheduler such as Airflow, Dagster or Prefect
- Advanced Scheduling: Self-hosted scheduler such as Airflow or Dagster

## Considerations

### Security

- All credentials are generated automatically and fetched safely programmatically via Azure Key Vault
- Where possible Azure Managed Identities or Azure Service Principals are prioritized and utilized

### Costs

- Automated restart/pause of Azure Synapse Dedicated Pools can be realized via Azure Pipelines or Azure Data Factory: https://docs.microsoft.com/en-us/azure/synapse-analytics/sql/how-to-pause-resume-pipelines
- dbt Scheduling Costs: Azure Pipelines vs Azure Data Factory + Azure Container Instance

## Additional Enhancements

- Sending all logs to centralized logging repository such as Azure Monitor (simple)
- Dynamic extraction of Azure Key Vault values from all automation scripts
- Adding dbt testing support (source freshness and tests)
- Adding dbt docs support (Terraform + Azure Container + CI/CD)
- Adding database setup project
- Adding database security setup project

## Copyright

© 2022 Divergent Insights Pty Ltd - <info@divergentinsights.com.au>