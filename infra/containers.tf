# © 2022 Divergent Insights Pty Ltd - <info@divergentinsights.com.au>

# Container registry
resource "azurerm_container_registry" "acr" {
  name                = "cr${var.stack_name}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Basic"
  tags                = var.custom_tags
}

# Creating Docker image manually
resource "null_resource" "build_dbtcore_image" {

  # You can uncomment this to aid local development and testing
  #triggers = {
  #  always_run = "${timestamp()}"
  #}

  provisioner "local-exec" {
    command = "az acr login --name $ACR_NAME && az acr build -t $IMAGE_TAG --registry $ACR_NAME ../dbtcore_image"

    # You can uncomment this to force using Powershell
    #interpreter = ["Powershell", "-Command"]

    environment = {
      ACR_NAME  = azurerm_container_registry.acr.name
      IMAGE_TAG = var.dbtcore_image_tag
    }
  }
  depends_on = [azurerm_container_registry.acr]
}

# Create the relevant Azure Container group to run the dbt image
resource "azurerm_container_group" "acg_dbt" {
  name                = "cg${var.stack_name}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  restart_policy      = "Never"
  os_type             = "Linux"

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.uai.id]
  }

  image_registry_credential {
    server   = azurerm_container_registry.acr.login_server
    username = data.azurerm_client_config.current.client_id
    password = var.TERRAFORM_SERVICE_PRINCIPAL_SECRET
  }

  container {
    name   = "dbtcoreazure"
    image  = "${azurerm_container_registry.acr.login_server}/${var.dbtcore_image_tag}"
    cpu    = 1
    memory = 1
    environment_variables = {
      "ENV_DBT_PROJECT_TAR"  = "/volume-dbt-projects/dbtproject.tar"
      "DBT_SYNAPSE_SERVER"   = azurerm_synapse_workspace.this.name
      "DBT_SYNAPSE_DATABASE" = azurerm_synapse_sql_pool.this.name
    }

    secure_environment_variables = {
      "DBT_SYNAPSE_USER"     = azurerm_key_vault_secret.sql_administrator_login.value
      "DBT_SYNAPSE_PASSWORD" = azurerm_key_vault_secret.sql_administrator_login_password.value
    }

    volume {
      name                 = "volume-dbt-projects"
      mount_path           = "/volume-dbt-projects/"
      read_only            = true
      storage_account_name = azurerm_storage_account.dbtcoreazure.name
      storage_account_key  = azurerm_storage_account.dbtcoreazure.primary_access_key
      share_name           = azurerm_storage_share.dbtcoreazure.name
    }

    # Port value must be defined (even when it is NOT required, which is our case)
    ports {
      port     = 9999
      protocol = "UDP"
    }
  }

  depends_on = [azurerm_container_registry.acr, null_resource.build_dbtcore_image]
  tags       = var.custom_tags
}

# Package the dbt project and upload on the Storage Account/Share
resource "null_resource" "dbt_project_tar" {

  triggers = {
    always_run = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = "cd .. && tar -cvzf dbtproject.tar dbtproject && az storage file upload --share-name $STORAGE_SHARE_NAME --source dbtproject.tar --account-name $STORAGE_ACCOUNT_NAME --account-key $STORAGE_ACCOUNT_PAK"

    # You can uncomment this to force using Powershell
    #interpreter = ["Powershell", "-Command"]

    environment = {
      STORAGE_SHARE_NAME   = azurerm_storage_share.dbtcoreazure.name
      STORAGE_ACCOUNT_NAME = azurerm_storage_account.dbtcoreazure.name
      STORAGE_ACCOUNT_PAK  = azurerm_storage_account.dbtcoreazure.primary_access_key
    }
  }
}
