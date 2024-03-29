# © 2022 Divergent Insights Pty Ltd - <info@divergentinsights.com.au>

variable "stack_name" {
  description = "The name of the stack"
  default     = "dbtcoreazure"
}

# Uppercase required due to ADO limitations
# See: https://gaunacode.com/terraform-input-variables-using-azure-devops
variable "TERRAFORM_SERVICE_PRINCIPAL_SECRET" {
  description = "Terraform Service Principal secret"
}

# Uppercase required due to ADO limitations
# See: https://gaunacode.com/terraform-input-variables-using-azure-devops
variable "SYNAPSE_LOGIN_PASSWORD" {
  description = "Terraform Service Principal secret"
}

variable "module_name" {
  default = "dbtonaz"
}

variable "module_short_name" {
  default = "dbtaz"
}

variable "azure_region" {
  default = "australiaeast"
}

variable "azure_region_short_code" {
  description = "region short code where resource is deployed"
  default     = "use1"
}

variable "custom_tags" {
  default = {
    "author"      = "Divergent Insights Pty Ltd"
    "owner"       = "Divergent Insights Pty Ltd"
    "description" = "Showcase how to use dbt Core on an Azure ecosystem"
  }
}

variable "dbtcore_image_tag" {
  default = "divergent-insights/dbtcore-azure:v1"
}
