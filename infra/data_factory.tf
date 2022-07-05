resource "azurerm_data_factory" "dbtcore_execution" {
  name                = "adf-${var.stack_name}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  identity {
    type = "SystemAssigned"
  }

  tags = var.custom_tags
}

## ADF should have access to kv to read the service principal
## information.
#resource "azurerm_key_vault_access_policy" "kv_adf_transform" {
#  key_vault_id = azurerm_key_vault.kv.id
#  tenant_id    = data.azurerm_client_config.current.tenant_id
#  object_id    = azurerm_data_factory.adf_transform.identity[0].principal_id
#
#  secret_permissions = ["get", "list"]
#}
#
#resource "azurerm_data_factory_linked_service_key_vault" "adf_kv_ls" {
#  name                = "ls_kv"
#  resource_group_name = azurerm_resource_group.rg.name
#  data_factory_name   = azurerm_data_factory.adf_transform.name
#  key_vault_id        = azurerm_key_vault.kv.id
#  description         = " Used for retrieving sp information. "
#}
#
#resource "azurerm_data_factory_pipeline" "acg_start_pipe" {
#  name                = "acg_start_and_wait_pipe"
#  resource_group_name = azurerm_resource_group.rg.name
#  data_factory_name   = azurerm_data_factory.adf_transform.name
#  description         = " A common pipeline that can be called to trigger the dbt ACG and wait for its completion."
#
#  parameters = {
#    #Azure container group, which hosts the dbt container
#    "acg_name" = azurerm_container_group.acg_dbt.name
#
#    # A rough estimate time for the data pipeline is expected to finish.
#    # specify in seconds
#    "sleep_time_potential_completion" = 300
#
#    # Azure tenant id
#    "az_tenant_id" = data.azurerm_client_config.current.tenant_id
#    # Azure subscription id
#    "az_sub_id" = data.azurerm_client_config.current.subscription_id
#    # The resource group which host the ACG
#    "acg_rg" = azurerm_resource_group.rg.name
#  }
#
#  activities_json = <<EOF_JSON
#
#[
#            {
#                "name": "kv_get_acr-sp",
#                "description": "Retrieves the service principal id, used for starting the ACG.",
#                "type": "WebActivity",
#                "dependsOn": [],
#                "policy": {
#                    "timeout": "7.00:00:00",
#                    "retry": 0,
#                    "retryIntervalInSeconds": 30,
#                    "secureOutput": false,
#                    "secureInput": false
#                },
#                "userProperties": [],
#                "typeProperties": {
#                    "url": "https://hmuse1dbtazkv01.vault.azure.net/secrets/acr-sp/?api-version=7.0",
#                    "method": "GET",
#                    "authentication": {
#                        "type": "MSI",
#                        "resource": "https://vault.azure.net"
#                    }
#                }
#            },
#            {
#                "name": "kv_get_acr-sp-scrt",
#                "description": "Retrieves the service principal secret, used for starting the ACG.",
#                "type": "WebActivity",
#                "dependsOn": [],
#                "policy": {
#                    "timeout": "7.00:00:00",
#                    "retry": 0,
#                    "retryIntervalInSeconds": 30,
#                    "secureOutput": false,
#                    "secureInput": false
#                },
#                "userProperties": [],
#                "typeProperties": {
#                    "url": "https://hmuse1dbtazkv01.vault.azure.net/secrets/acr-sp-scrt/?api-version=7.0",
#                    "method": "GET",
#                    "authentication": {
#                        "type": "MSI",
#                        "resource": "https://vault.azure.net"
#                    }
#                }
#            },
#            {
#                "name": "get_access_token",
#                "description": "Get the access token, so that we can use this in subsequent calls.",
#                "type": "WebActivity",
#                "dependsOn": [
#                    {
#                        "activity": "kv_get_acr-sp",
#                        "dependencyConditions": [
#                            "Succeeded"
#                        ]
#                    },
#                    {
#                        "activity": "kv_get_acr-sp-scrt",
#                        "dependencyConditions": [
#                            "Succeeded"
#                        ]
#                    }
#                ],
#                "policy": {
#                    "timeout": "7.00:00:00",
#                    "retry": 0,
#                    "retryIntervalInSeconds": 30,
#                    "secureOutput": false,
#                    "secureInput": false
#                },
#                "userProperties": [],
#                "typeProperties": {
#                    "url": {
#                        "value": "@concat('https://login.microsoftonline.com/', pipeline().parameters.az_tenant_id,\n'/oauth2/token')",
#                        "type": "Expression"
#                    },
#                    "method": "POST",
#                    "headers": {
#                        "Content-Type": "application/x-www-form-urlencoded"
#                    },
#                    "body": {
#                        "value": "@concat(\n'grant_type=client_credentials&client_id=',\nactivity('kv_get_acr-sp').output.value\n,'&client_secret=',\nactivity('kv_get_acr-sp-scrt').output.value\n,'&resource=https%3A%2F%2Fmanagement.azure.com%2F'\n)",
#                        "type": "Expression"
#                    }
#                }
#            },
#            {
#                "name": "start_acg",
#                "description": "Start the specified acg instance (parameter).",
#                "type": "WebActivity",
#                "dependsOn": [
#                    {
#                        "activity": "get_access_token",
#                        "dependencyConditions": [
#                            "Succeeded"
#                        ]
#                    }
#                ],
#                "policy": {
#                    "timeout": "7.00:00:00",
#                    "retry": 0,
#                    "retryIntervalInSeconds": 30,
#                    "secureOutput": false,
#                    "secureInput": false
#                },
#                "userProperties": [],
#                "typeProperties": {
#                    "url": {
#                        "value": "@concat(\n'https://management.azure.com/subscriptions/',\npipeline().parameters.az_sub_id\n,'/resourceGroups/',\npipeline().parameters.acg_rg\n,'/providers/Microsoft.ContainerInstance/containerGroups/',\npipeline().parameters.acg_name\n,'/start?api-version=2019-12-01'\n)",
#                        "type": "Expression"
#                    },
#                    "method": "POST",
#                    "headers": {
#                        "Authorization": {
#                            "value": "@concat(\n 'Bearer ',\n  activity('get_access_token').output.access_token\n)",
#                            "type": "Expression"
#                        }
#                    },
#                    "body": {
#                      "value": "{}",
#                      "type": "Expression"
#                    }
#                }
#            },
#            {
#                "name": "Wait_for_acg_finish",
#                "description": "Wait for ACG to finish completion, by x no of minutes.",
#                "type": "Wait",
#                "dependsOn": [
#                    {
#                        "activity": "start_acg",
#                        "dependencyConditions": [
#                            "Succeeded"
#                        ]
#                    }
#                ],
#                "userProperties": [],
#                "typeProperties": {
#                    "waitTimeInSeconds": {
#                        "value": "@pipeline().parameters.sleep_time_potential_completion",
#                        "type": "Expression"
#                    }
#                }
#            },
#            {
#                "name": "get_acg_status",
#                "description": "Get the status of the ACG to confirm if it finished or still running",
#                "type": "WebActivity",
#                "dependsOn": [
#                    {
#                        "activity": "Wait_for_acg_finish",
#                        "dependencyConditions": [
#                            "Succeeded"
#                        ]
#                    }
#                ],
#                "policy": {
#                    "timeout": "7.00:00:00",
#                    "retry": 0,
#                    "retryIntervalInSeconds": 30,
#                    "secureOutput": false,
#                    "secureInput": false
#                },
#                "userProperties": [],
#                "typeProperties": {
#                    "url": {
#                        "value": "@concat(\n'https://management.azure.com/subscriptions/',\npipeline().parameters.az_sub_id\n,'/resourceGroups/',\npipeline().parameters.acg_rg\n,'/providers/Microsoft.ContainerInstance/containerGroups/',\npipeline().parameters.acg_name\n,'?api-version=2019-12-01'\n)",
#                        "type": "Expression"
#                    },
#                    "method": "GET",
#                    "headers": {
#                        "Authorization": {
#                            "value": "@concat(\n 'Bearer ',\n  activity('get_access_token').output.access_token\n)",
#                            "type": "Expression"
#                        }
#                    }
#                }
#            }
#        ]
#
#EOF_JSON
#
#}
#