resource "azurerm_resource_group" "rg" {
  name     = "rg-${var.stack_name}"
  location = var.azure_region
  tags     = var.custom_tags
}
