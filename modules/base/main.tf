variable "tags" {
  type    = map(any)
  default = {}
}

variable "location" {}
variable "name" {}

locals {
  azurerm_resource_group_name = "${var.name}-rg"
}

resource "azurerm_resource_group" "this" {
  name     = local.azurerm_resource_group_name
  location = var.location
  tags     = var.tags
}

resource "azurerm_container_registry" "this" {
  name                 = "${var.name}reg" # alpha numeric characters only are allowed 
  resource_group_name  = azurerm_resource_group.this.name
  location             = azurerm_resource_group.this.location
  sku                  = "Standard"
  admin_enabled        = true
  trust_policy_enabled = true
  tags                 = var.tags
}

resource "azurerm_service_plan" "this" {
  name                = "${var.name}-plan"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  os_type             = "Linux"
  # checkov:skip=CKV_AZURE_211:"Ensure App Service plan suitable for production use"
  sku_name = "B2"
  # checkov:skip=CKV_AZURE_212:"Ensure App Service has a minimum number of instances for failover"
  worker_count = 1
  # checkov:skip=CKV_AZURE_225:"Ensure the App Service Plan is zone redundant"
  zone_balancing_enabled = false
  tags                   = var.tags
}

resource "azurerm_application_insights" "this" {
  name                = "${var.name}-appinsights"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  application_type    = "other"
}

output "azurerm_resource_group_id" {
  value = azurerm_resource_group.this.id
}

output "azurerm_resource_group_name" {
  value = local.azurerm_resource_group_name
}

output "azurerm_container_registry_id" {
  value = azurerm_container_registry.this.id
}

output "azurerm_container_registry_login_server" {
  value = azurerm_container_registry.this.login_server
}

output "azurerm_container_registry_admin_username" {
  sensitive = true
  value     = azurerm_container_registry.this.admin_username
}

output "azurerm_container_registry_admin_password" {
  sensitive = true
  value     = azurerm_container_registry.this.admin_password
}

output "azurerm_service_plan_id" {
  value = azurerm_service_plan.this.id
}

output "application_insights_connection_string" {
  value = azurerm_application_insights.this.connection_string
}

output "application_insights_instrumentation_key" {
  value = azurerm_application_insights.this.instrumentation_key
}
