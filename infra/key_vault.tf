# Creating vanilla Key Vault
resource "azurerm_key_vault" "kv" {
  name                = "kv${var.stack_name}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku_name            = "standard"
  tenant_id           = data.azurerm_client_config.current.tenant_id
  tags                = var.custom_tags
}

# Ensure the Terraform user has write access to Key Vault
resource "azurerm_key_vault_access_policy" "terraform_user" {
  key_vault_id = azurerm_key_vault.kv.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id
  #object_id = azurerm_user_assigned_identity.uai.principal_id

  secret_permissions = ["Get", "List", "Set", "Delete", "Purge"]
}

# Store the Storage Account (sa) Shared Access Signatures (SAS)
# in Key Vault (kv) as it will required to copy
# dbt projects into the docker image
#resource "azurerm_key_vault_secret" "storage_account" {
#  name         = "kvs-sa-sas-${var.stack_name}"
#  value        = azurerm_storage_account.dbtcoreazure.primary_access_key
#  content_type = "SAS key for accessing the storage account, which holds the dbt code"
#  key_vault_id = azurerm_key_vault.kv.id
#  depends_on   = [azurerm_key_vault_access_policy.terraform_user]
#  tags         = var.custom_tags
#}

# Store the service principal credentials
# to enable to deploy aci on the fly.
#resource "azurerm_key_vault_secret" "terraform_user" {
#  name         = "terraform-user-id"
#  value        = data.azurerm_client_config.current.client_id
#  content_type = "Terraform user name"
#  key_vault_id = azurerm_key_vault.kv.id
#  depends_on   = [azurerm_key_vault_access_policy.terraform_user]
#  tags         = var.custom_tags
#}
#
#resource "azurerm_key_vault_secret" "kvs_acr_sp_scrt" {
#  name         = "terraform-user-secret"
#  value        = var.terraform_service_principal_secret
#  content_type = "Terraform user password"
#  key_vault_id = azurerm_key_vault.kv.id
#  #depends_on   = [azurerm_key_vault_access_policy.terraform_user]
#  tags = var.custom_tags
#}

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

resource "random_password" "sql_administrator_login" {
  length  = 16
  special = false
}

resource "azurerm_key_vault_secret" "sql_administrator_login_password" {
  name         = "synpase-sql-administrator-login-password"
  value        = random_password.sql_administrator_login.result
  content_type = "Synapse Admin Login - Password"
  key_vault_id = azurerm_key_vault.kv.id
  depends_on   = [azurerm_key_vault_access_policy.terraform_user]
  tags         = var.custom_tags
}

#resource "azurerm_key_vault_secret" "kvs_sflk_conn" {
#  name         = "sflk-conn"
#  value        = <<SCRT_EOF
#		{
#       'SNOWSQL_ACCOUNT': 'abc.us-east-1',
#       'SNOWSQL_USER': 'SOMEBODY',
#       'DBT_PASSWORD': 'abracadabra',
#       'SNOWSQL_ROLE': 'PUBLIC',
#       'SNOWSQL_DATABASE': 'DEMO_DB',
#       'SNOWSQL_WAREHOUSE': 'DEMO_WH'
#     }
#	SCRT_EOF
#  content_type = "Synapse connection info"
#  key_vault_id = azurerm_key_vault.kv.id
#  depends_on   = [azurerm_key_vault_access_policy.kv_acp_deployer]
#  tags         = var.custom_tags
#}
#