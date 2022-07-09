# © 2022 Divergent Insights Pty Ltd - <info@divergentinsights.com.au>


resource "azurerm_data_factory" "dbtcore_execution" {
  name                = "adf-${var.stack_name}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  identity {
    type = "SystemAssigned"
  }

  tags = var.custom_tags
}

# ADF Permissions: Key Vault Access Policy
#resource "azurerm_key_vault_access_policy" "kv_adf_transform" {
#  key_vault_id = azurerm_key_vault.kv.id
#  tenant_id    = data.azurerm_client_config.current.tenant_id
#  object_id    = azurerm_data_factory.dbtcore_execution.identity[0].principal_id
#
#  secret_permissions = ["Get", "List"]
#}

resource "azurerm_data_factory_pipeline" "dbt_execution" {
  name            = "dbt Execution"
  data_factory_id = azurerm_data_factory.dbtcore_execution.id
  description     = "Pipeline that executes dbt using an Azure Container Instance"

  parameters = {
    "AzureContainerGroup" = azurerm_container_group.acg_dbt.name
    "AzureResourceGroup"  = azurerm_resource_group.rg.name
    "AzureSubscriptionId" = data.azurerm_client_config.current.subscription_id
    "AzureTenantId"       = data.azurerm_client_config.current.tenant_id
    "SleepTime"           = 120
  }

  activities_json = <<EOF_JSON
[
  {
      "name": "Service Principal Id",
      "description": "Service Principal required to execute the Azure Container Group running dbt",
      "type": "WebActivity",
      "dependsOn": [],
      "policy": {
          "timeout": "7.00:00:00",
          "retry": 0,
          "retryIntervalInSeconds": 30,
          "secureOutput": true,
          "secureInput": false
      },
      "userProperties": [],
      "typeProperties": {
          "url": "https://kvdbtcoreazure.vault.azure.net/secrets/terraform-user-id/?api-version=7.0",
          "method": "GET",
          "authentication": {
              "type": "MSI",
              "resource": "https://vault.azure.net"
          }
      }
  },
  {
      "name": "Service Principal Secret",
      "description": "Service Principal required to execute the Azure Container Group running dbt",
      "type": "WebActivity",
      "dependsOn": [],
      "policy": {
          "timeout": "7.00:00:00",
          "retry": 0,
          "retryIntervalInSeconds": 30,
          "secureOutput": true,
          "secureInput": false
      },
      "userProperties": [],
      "typeProperties": {
          "url": "https://kvdbtcoreazure.vault.azure.net/secrets/terraform-user-secret/?api-version=7.0",
          "method": "GET",
          "authentication": {
              "type": "MSI",
              "resource": "https://vault.azure.net"
          }
      }
  },
  {
      "name": "Access Token",
      "description": "Bearer token to authenticate with Azure Container Group to launch the Azure Container Instance",
      "type": "WebActivity",
      "dependsOn": [
          {
              "activity": "Service Principal Id",
              "dependencyConditions": [
                  "Succeeded"
              ]
          },
          {
              "activity": "Service Principal Secret",
              "dependencyConditions": [
                  "Succeeded"
              ]
          }
      ],
      "policy": {
          "timeout": "7.00:00:00",
          "retry": 0,
          "retryIntervalInSeconds": 30,
          "secureOutput": true,
          "secureInput": false
      },
      "userProperties": [],
      "typeProperties": {
          "url": {
              "value": "@concat('https://login.microsoftonline.com/', pipeline().parameters.AzureTenantId,\n'/oauth2/token')",
              "type": "Expression"
          },
          "method": "POST",
          "headers": {
              "Content-Type": "application/x-www-form-urlencoded"
          },
          "body": {
              "value": "@concat(\n'grant_type=client_credentials&client_id=',\nactivity('Service Principal Id').output.value\n,'&client_secret=',\nactivity('Service Principal Secret').output.value\n,'&resource=https%3A%2F%2Fmanagement.azure.com%2F'\n)",
              "type": "Expression"
          }
      }
  },
  {
      "name": "Run dbt",
      "description": "Execute dbt using the Azure Container Instance",
      "type": "WebActivity",
      "dependsOn": [
          {
              "activity": "Access Token",
              "dependencyConditions": [
                  "Succeeded"
              ]
          }
      ],
      "policy": {
          "timeout": "7.00:00:00",
          "retry": 0,
          "retryIntervalInSeconds": 30,
          "secureOutput": false,
          "secureInput": false
      },
      "userProperties": [],
      "typeProperties": {
          "url": {
              "value": "@concat(\n'https://management.azure.com/subscriptions/',\npipeline().parameters.AzureSubscriptionId\n,'/resourceGroups/',\npipeline().parameters.AzureResourceGroup\n,'/providers/Microsoft.ContainerInstance/containerGroups/',\npipeline().parameters.AzureContainerGroup\n,'/start?api-version=2019-12-01'\n)",
              "type": "Expression"
          },
          "method": "POST",
          "headers": {
              "Authorization": {
                  "value": "@concat(\n 'Bearer ',\n  activity('Access Token').output.access_token\n)",
                  "type": "Expression"
              }
          },
          "body": {
              "value": "{}",
              "type": "Expression"
          }
      }
  },
  {
      "name": "Wait for dbt execution",
      "description": "Wait for ACG to finish completion, by x no of minutes.",
      "type": "Wait",
      "dependsOn": [
          {
              "activity": "Run dbt",
              "dependencyConditions": [
                  "Succeeded"
              ]
          }
      ],
      "userProperties": [],
      "typeProperties": {
          "waitTimeInSeconds": {
              "value": "@pipeline().parameters.SleepTime",
              "type": "Expression"
          }
      }
  },
  {
      "name": "dbt Run Status",
      "description": "Get the status of the dbt execution from the Azure Container Instance",
      "type": "WebActivity",
      "dependsOn": [
          {
              "activity": "Wait for dbt execution",
              "dependencyConditions": [
                  "Succeeded"
              ]
          }
      ],
      "policy": {
          "timeout": "7.00:00:00",
          "retry": 0,
          "retryIntervalInSeconds": 30,
          "secureOutput": false,
          "secureInput": false
      },
      "userProperties": [],
      "typeProperties": {
          "url": {
              "value": "@concat(\n'https://management.azure.com/subscriptions/',\npipeline().parameters.AzureSubscriptionId\n,'/resourceGroups/',\npipeline().parameters.AzureResourceGroup\n,'/providers/Microsoft.ContainerInstance/containerGroups/',\npipeline().parameters.AzureContainerGroup\n,'?api-version=2019-12-01'\n)",
              "type": "Expression"
          },
          "method": "GET",
          "headers": {
              "Authorization": {
                  "value": "@concat(\n 'Bearer ',\n  activity('Access Token').output.access_token\n)",
                  "type": "Expression"
              }
          }
      }
  }
]
EOF_JSON
}
