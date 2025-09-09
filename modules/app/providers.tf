terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.86.0"
    }
    docker = {
      source  = "kreuzwerker/docker"
      version = ">=3.6.2"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "docker" {
  registry_auth {
    address  = var.acr_login_server   # data.azurerm_container_registry.acr.login_server
    username = var.acr_admin_username # data.azurerm_container_registry.acr.admin_username
    password = var.acr_admin_password # data.azurerm_container_registry.acr.admin_password
  }
}
