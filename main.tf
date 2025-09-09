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
    random = "~> 3.4.3"
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
  prefix = "demo${random_pet.name.id}"
  tags = merge(
    {
      Workspace = terraform.workspace
      Terraform = "true"
    },
  )
}

# main
resource "random_pet" "name" {
  separator = ""
}

module "base" {
  source = "./modules/base"

  location = var.location
  name     = local.prefix
  tags     = local.tags
}

module "app" {
  source = "./modules/app"

  location            = var.location
  name                = local.prefix
  resource_group_id   = module.base.azurerm_resource_group_id
  resource_group_name = module.base.azurerm_resource_group_name
  image_name          = local.prefix
  image_context       = "${path.module}/"
  docker_image_name   = "${local.prefix}.azurecr.io/demo:latest"
  dockerfile          = "${path.module}/Dockerfile.web"
  service_plan_id     = module.base.azurerm_service_plan_id
  docker_registry_url = "https://${module.base.azurerm_container_registry_login_server}"
  acr_login_server    = module.base.azurerm_container_registry_login_server
  acr_admin_username  = module.base.azurerm_container_registry_admin_username
  acr_admin_password  = module.base.azurerm_container_registry_admin_password
  tags                = local.tags
}

output "app" {
  value = {
    tags             = local.tags
    default_hostname = module.app.default_hostname
  }
}

