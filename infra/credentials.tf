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

#resource "azurerm_role_assignment" "key_vault" {
#  scope                = azurerm_storage_account.synapse.id
#  role_definition_name = "Storage Account Key Operator Service Role"
#  principal_id         = azurerm_user_assigned_identity.uai.principal_id
#}

## The user assigned identity should be able to read the
## key vault, which is where the database connectivity information is stored
#resource "azurerm_key_vault_access_policy" "uai_kv" {
#  key_vault_id = azurerm_key_vault.kv.id
#  tenant_id    = data.azurerm_client_config.current.tenant_id
#  object_id    = azurerm_user_assigned_identity.uai.principal_id
#
#  secret_permissions = ["get", "list", "set"]
#}
#






#resource "azuread_application" "this" {
#  display_name = "dbtcoreazure"
#}
#
#resource "azuread_service_principal" "this" {
#  application_id               = azuread_application.this.application_id
#  app_role_assignment_required = false
#}
#
#resource "azuread_service_principal_password" "this" {
#  service_principal_id = azuread_service_principal.this.id
#  value                = "WeAreDivergent#1"
#}
#
#resource "azurerm_role_assignment" "this" {
#  scope                = azurerm_storage_account.synapse.id
#  role_definition_name = "Storage Blob Data Contributor"
#  principal_id         = azuread_service_principal.this.object_id
#}