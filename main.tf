terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.86.0"
    }
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.6.2"
    }
  }
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs
provider "azurerm" {
  # OpenID Connect is an authentication method that uses short-lived tokens
  #use_oidc = true
  #resource_provider_registrations = "none" # This is only required when the User, Service Principal, or Identity running Terraform lacks the permissions to register Azure Resource Providers.
  features {
    #resource_group {
    #  prevent_deletion_if_contains_resources = true
    #}
  }
}

# variables
variable "location" {
  default = "northeurope"
}

locals {
  name = module.naming.resource_group.name_unique
  tags = merge(
    {
      Workspace = terraform.workspace
    },
  )
}

# main

# This ensures we have unique CAF compliant names for our resources.
module "naming" {
  source = "git::https://github.com/Azure/terraform-azurerm-naming.git?ref=75d5afae4cb01f4446025e81f76af6b60c1f927b" # commit hash of version 5.0.0
}

module "base" {
  source = "./modules/base"

  location = var.location
  name     = local.name
  tags     = local.tags
}

module "api" {
  source = "./modules/app"

  location            = var.location
  name                = "api${local.name}"
  resource_group_id   = module.base.azurerm_resource_group_id
  resource_group_name = module.base.azurerm_resource_group_name
  image_context       = path.module
  docker_image_name   = "${local.name}.azurecr.io/api:latest"
  dockerfile          = "${path.module}/api/Dockerfile"
  service_plan_id     = module.base.azurerm_service_plan_id
  acr_login_server    = module.base.azurerm_container_registry_login_server
  acr_admin_username  = module.base.azurerm_container_registry_admin_username
  acr_admin_password  = module.base.azurerm_container_registry_admin_password
  site_config = {
    docker_registry_url = "https://${module.base.azurerm_container_registry_login_server}"
  }
  app_settings = {
    "WEBSITES_PORT"                         = "8080"
    "APPLICATIONINSIGHTS_CONNECTION_STRING" = module.base.application_insights_connection_string
    "APPINSIGHTS_INSTRUMENTATIONKEY"        = module.base.application_insights_instrumentation_key
  }
  tags = merge({ api = module.naming.function_app.name_unique }, local.tags)
}

module "web" {
  source = "./modules/app"

  location            = var.location
  name                = "web${local.name}"
  resource_group_id   = module.base.azurerm_resource_group_id
  resource_group_name = module.base.azurerm_resource_group_name
  image_context       = path.module
  docker_image_name   = "${local.name}.azurecr.io/web:latest"
  dockerfile          = "${path.module}/web/Dockerfile"
  service_plan_id     = module.base.azurerm_service_plan_id
  acr_login_server    = module.base.azurerm_container_registry_login_server
  acr_admin_username  = module.base.azurerm_container_registry_admin_username
  acr_admin_password  = module.base.azurerm_container_registry_admin_password
  site_config = {
    docker_registry_url = "https://${module.base.azurerm_container_registry_login_server}"
  }
  app_settings = {
    "WEBSITES_PORT"                         = "80"
    "APPLICATIONINSIGHTS_CONNECTION_STRING" = module.base.application_insights_connection_string
    "APPINSIGHTS_INSTRUMENTATIONKEY"        = module.base.application_insights_instrumentation_key
    "API_URI"                               = "${module.api.default_hostname}:8080"
  }
  tags = merge({ app = module.naming.function_app.name_unique }, local.tags)
}

output "location" {
  description = "The location of the resource."
  value       = var.location
}

output "api" {
  value = {
    tags             = local.tags
    default_hostname = module.api.default_hostname
  }
}

output "web" {
  value = {
    tags             = local.tags
    default_hostname = module.web.default_hostname
  }
}
