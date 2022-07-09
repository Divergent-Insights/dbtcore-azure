# © 2022 Divergent Insights Pty Ltd - <info@divergentinsights.com.au>


resource "azurerm_storage_account" "dbtcoreazure" {
  name                     = "sta${var.stack_name}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  static_website {
    index_document = "index.html"
  }

  tags                     = var.custom_tags
}

resource "azurerm_storage_data_lake_gen2_filesystem" "dlstorage" {
  name               = "stdl${var.stack_name}"
  storage_account_id = azurerm_storage_account.dbtcoreazure.id
  depends_on         = [azurerm_storage_account.dbtcoreazure]
}

#resource "azurerm_storage_container" "static" {
#  name                  = "static"
#  storage_account_name  = azurerm_storage_account.dbtcoreazure.name
#  container_access_type = "private"
#}

resource "azurerm_storage_share" "dbtcoreazure" {
  name                 = "share"
  storage_account_name = azurerm_storage_account.dbtcoreazure.name
  quota                = 1
  depends_on           = [azurerm_storage_account.dbtcoreazure]
}
