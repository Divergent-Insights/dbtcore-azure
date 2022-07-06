# © 2022 Divergent Insights Pty Ltd - <info@divergentinsights.com.au>


resource "azurerm_synapse_workspace" "this" {
  name                                 = "syn-workspace-${var.stack_name}" # Must be globally unique
  resource_group_name                  = azurerm_resource_group.rg.name
  location                             = azurerm_resource_group.rg.location
  storage_data_lake_gen2_filesystem_id = azurerm_storage_data_lake_gen2_filesystem.dlstorage.id
  sql_administrator_login              = "sqladmin"
  sql_administrator_login_password     = "WeAreDivergent#1"
  #sql_administrator_login          = azurerm_key_vault_secret.sql_administrator_login.value
  #sql_administrator_login_password = azurerm_key_vault_secret.sql_administrator_login_password.value

  aad_admin = [
    {
      login = "AzureAD Admin"
      object_id = data.azurerm_client_config.current.object_id
      tenant_id = data.azurerm_client_config.current.tenant_id
    }
  ]

  identity {
    type = "SystemAssigned"
  }

  tags = var.custom_tags
}

resource "azurerm_synapse_sql_pool" "this" {
  name                 = "syn_dedicatedpool_${var.stack_name}" # Must be globally unique
  synapse_workspace_id = azurerm_synapse_workspace.this.id
  sku_name             = "DW100c"
  create_mode          = "Default"
  tags                 = var.custom_tags
}

resource "azurerm_synapse_firewall_rule" "allow_azure_services" {
  name                 = "AllowAll"
  synapse_workspace_id = azurerm_synapse_workspace.this.id
  start_ip_address     = "0.0.0.0"
  end_ip_address       = "255.255.255.255"
}

#resource "azurerm_role_assignment" "this" {
#  scope                = azurerm_storage_account.synapse.id
#  role_definition_name = "Storage Blob Data Contributor"
#  principal_id         = data.azurerm_client_config.current.object_id
#}
