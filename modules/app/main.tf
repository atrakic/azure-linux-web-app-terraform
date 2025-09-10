variable "tags" {
  type    = map(any)
  default = {}
}

variable "location" {}
variable "name" {}
variable "resource_group_id" {}
variable "resource_group_name" {}
variable "image_name" {}
variable "image_context" {}
variable "docker_image_name" {}
variable "service_plan_id" {}
variable "docker_registry_url" {}
variable "acr_login_server" {}
variable "acr_admin_username" {}
variable "acr_admin_password" {}
variable "dockerfile" { default = "Dockerfile" }

resource "docker_registry_image" "this" {
  name          = docker_image.this.name
  keep_remotely = false
}

resource "docker_image" "this" {
  name = var.docker_image_name # "${data.azurerm_container_registry.acr.login_server}/${local.image_name}"
  #keep_locally = false

  build {
    no_cache   = true
    dockerfile = var.dockerfile
    context    = var.image_context
  }
}

resource "azurerm_application_insights" "this" {
  name                = "${var.name}-appinsights"
  location            = var.location
  resource_group_name = var.resource_group_name
  application_type    = "other"
}

resource "azurerm_linux_web_app" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  service_plan_id     = var.service_plan_id
  https_only          = true

  site_config {
    application_stack {
      docker_image_name        = docker_image.this.name  # local.image_name
      docker_registry_url      = var.docker_registry_url # "https://${data.azurerm_container_registry.acr.login_server}"
      docker_registry_username = var.acr_admin_username
      docker_registry_password = var.acr_admin_password
    }

    container_registry_use_managed_identity = true
    always_on                               = true
    ftps_state                              = "FtpsOnly"
    health_check_path                       = "/" # <change-here>
  }

  app_settings = {
    "APPLICATIONINSIGHTS_CONNECTION_STRING" = azurerm_application_insights.this.connection_string
    "APPINSIGHTS_INSTRUMENTATIONKEY"        = azurerm_application_insights.this.instrumentation_key
    "WEBSITES_PORT"                         = "8080"
  }

  identity {
    type = "SystemAssigned"
  }

  lifecycle {
    ignore_changes = [
      site_config.0.application_stack
    ]
  }

  depends_on = [
    docker_registry_image.this
  ]

  tags = var.tags
}

resource "azurerm_role_assignment" "this" {
  scope                = var.resource_group_id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_linux_web_app.this.identity[0].principal_id
}

output "default_hostname" {
  value = azurerm_linux_web_app.this.default_hostname
}
