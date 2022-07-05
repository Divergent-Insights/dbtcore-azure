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

  triggers = {
    always_run = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = <<BUILD_CMD_EOF
      az acr login --name crdbtcoreazure
      az acr build -t divergent-insights/dbtcore-azure:v1 --registry crdbtcoreazure ../dbtcore_image
    BUILD_CMD_EOF

    environment = {
      ACR       = azurerm_container_registry.acr.name
      IMAGE_TAG = var.dbtcore_image_tag
    }
  }
  depends_on = [azurerm_container_registry.acr]
}

resource "azurerm_container_group" "acg_dbt" {
  name                = "cg${var.stack_name}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  restart_policy      = "Never"
  os_type             = "Linux"

  # Though this is not needed, its a current bug in the provider. we are
  # opening up a dummy port for now. may be in the future this will get fixed.
  #ip_address_type = "Public"

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.uai.id]
  }

  image_registry_credential {
    server   = azurerm_container_registry.acr.login_server
    username = data.azurerm_client_config.current.client_id
    password = var.terraform_service_principal_secret
  }

  container {
    name   = "dbtcoreazure"
    image  = "${azurerm_container_registry.acr.login_server}/${var.dbtcore_image_tag}:v1"
    cpu    = 1
    memory = 1
    environment_variables = {
      #"ENV_AZSUB"        = data.azurerm_client_config.current.subscription_id
      #"ENV_RG"           = azurerm_resource_group.rg.name
      #"ENV_KV_URL"       = azurerm_key_vault.kv.vault_uri
      #"ENV_KV_SFLK"      = azurerm_key_vault_secret.kvs_sflk_conn.name
      "ENV_DBT_PROJECT_TAR" = "/volume-dbt-projects/data.tar"
      #"ENV_DBT_RUN_CMD"  = "dbtcore_image/dbt_datapipeline.sh"
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

resource "null_resource" "dbt_project_tar" {

  triggers = {
    always_run = "${timestamp()}"
  }
      #tar -cvzf ../data.tar ../data
  provisioner "local-exec" {
    command = "az storage file upload --share-name share --source ../data.tar --account-name $env:storage_account_name --account-key $env:storage_account_pak"

    interpreter = ["Powershell", "-Command"]

    environment = {
      storage_share_name   = azurerm_storage_share.dbtcoreazure.name
      storage_account_name = azurerm_storage_account.dbtcoreazure.name
      storage_account_pak  = azurerm_storage_account.dbtcoreazure.primary_access_key
    }
  }
}
