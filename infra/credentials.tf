# © 2022 Divergent Insights Pty Ltd - <info@divergentinsights.com.au>

resource "azurerm_user_assigned_identity" "uai" {
  name                = "id-ua-${var.stack_name}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
}

# Allow the UAI to access the storage account
resource "azurerm_role_assignment" "storage_account" {
  scope                = azurerm_storage_account.dbtcoreazure.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_user_assigned_identity.uai.principal_id
}
