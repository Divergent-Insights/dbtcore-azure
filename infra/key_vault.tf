# © 2022 Divergent Insights Pty Ltd - <info@divergentinsights.com.au>

# Creating vanilla Key Vault
resource "azurerm_key_vault" "kv" {
  name                = "kv${var.stack_name}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku_name            = "standard"
  tenant_id           = data.azurerm_client_config.current.tenant_id

  tags = var.custom_tags
}

# Ensure the Terraform user has relevant access to Key Vault
resource "azurerm_key_vault_access_policy" "terraform_user" {
  key_vault_id = azurerm_key_vault.kv.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  secret_permissions = ["Get", "List", "Set", "Delete", "Purge"]
}

# Ensure Azure Data Factory has relevant access to Key Vault
resource "azurerm_key_vault_access_policy" "adf" {
  key_vault_id = azurerm_key_vault.kv.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_data_factory.dbtcore_execution.identity[0].principal_id

  secret_permissions = ["Get", "List", "Set", "Delete", "Purge"]
}

# Terraform user credentials
# This is required by Azure Data Factory to fetch the credentials
# that will be used to execute dbt via ACG/ACI
resource "azurerm_key_vault_secret" "terraform_user" {
  name         = "terraform-user-id"
  value        = data.azurerm_client_config.current.client_id
  content_type = "Terraform user name"
  key_vault_id = azurerm_key_vault.kv.id
  depends_on   = [azurerm_key_vault_access_policy.terraform_user]
  tags         = var.custom_tags
}

resource "azurerm_key_vault_secret" "kvs_acr_sp_scrt" {
  name         = "terraform-user-secret"
  value        = var.TERRAFORM_SERVICE_PRINCIPAL_SECRET
  content_type = "Terraform user password"
  key_vault_id = azurerm_key_vault.kv.id
  depends_on   = [azurerm_key_vault_access_policy.terraform_user]
  tags         = var.custom_tags
}

# Synapse login credentials
# Only required during setup and can be disabled
resource "azurerm_key_vault_secret" "sql_administrator_login" {
  name         = "synapse-sql-administrator-login"
  value        = "sqladmin"
  content_type = "Synapse Admin Login - User"
  key_vault_id = azurerm_key_vault.kv.id
  depends_on   = [azurerm_key_vault_access_policy.terraform_user]
  tags         = var.custom_tags
}

resource "azurerm_key_vault_secret" "sql_administrator_login_password" {
  name         = "synpase-sql-administrator-login-password"
  value        = var.SYNAPSE_LOGIN_PASSWORD
  content_type = "Synapse Admin Login - Password"
  key_vault_id = azurerm_key_vault.kv.id
  depends_on   = [azurerm_key_vault_access_policy.terraform_user]
  tags         = var.custom_tags
}
