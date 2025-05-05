terraform {
  backend "local" {}

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.117.1"
    }
  }
  required_version = ">= 1.0.0"
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "bootstrap_rg" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_storage_account" "bootstrap_storage" {
  name                            = var.storage_account_name
  resource_group_name             = azurerm_resource_group.bootstrap_rg.name
  location                        = azurerm_resource_group.bootstrap_rg.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false
  shared_access_key_enabled       = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "azurerm_storage_container" "bootstrap_container" {
  name                  = var.container_name
  storage_account_name  = azurerm_storage_account.bootstrap_storage.name
  container_access_type = "private"
}
