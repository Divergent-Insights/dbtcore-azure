# Development Setup (All Microsoft and Windows)

## Terraform
# Hello world example: https://learn.hashicorp.com/tutorials/terraform/azure-build?in=terraform/azure-get-started
# Naming convention: https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming

## Azure CLI Installation
In a PowerShell Administrator console run
$ProgressPreference = 'SilentlyContinue'; Invoke-WebRequest -Uri https://aka.ms/installazurecliwindows -OutFile .\AzureCLI.msi; Start-Process msiexec.exe -Wait -ArgumentList '/I AzureCLI.msi /quiet'; rm .\AzureCLI.msi

# Obtain your Azure subscription id
az login

# Set your subscription
az account set --subscription "my-subscription-id"

# Create a Service Principal
az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/my-subscription-id"
az ad sp create-for-rbac --role="Owner" --scopes="/subscriptions/my-subscription-id"
az ad sp create-for-rbac --role="Owner" --scopes="/subscriptions/9feb9ec3-d1be-4df4-8af9-b7a8da1e3de6"
az ad sp create-for-rbac --role="Owner" --scopes="/subscriptions/9feb9ec3-d1be-4df4-8af9-b7a8da1e3de6" --name terraform
az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/9feb9ec3-d1be-4df4-8af9-b7a8da1e3de6" --name terraform


## Environment Variables
$Env:ARM_CLIENT_ID = "<APPID_VALUE>"
$Env:ARM_CLIENT_SECRET = "<PASSWORD_VALUE>"
$Env:ARM_SUBSCRIPTION_ID = "<SUBSCRIPTION_ID>"
$Env:ARM_TENANT_ID = "<TENANT_VALUE>"