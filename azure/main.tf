terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.0.0"
    }
  }
}


# Azure Provider
provider "azurerm" {
  features {}
  subscription_id = "584f8a59-dcda-4698-a720-39e3963a9708"
}

# Resource Group
resource "azurerm_resource_group" "vpn_rg" {
  name     = "shadowsocks-rg"
  location = "switzerlandnorth"
}

# Container App Environment
resource "azurerm_container_app_environment" "vpn_env" {
  name                = "shadowsocks-env"
  location            = azurerm_resource_group.vpn_rg.location
  resource_group_name = azurerm_resource_group.vpn_rg.name
}


# Container App
resource "azurerm_container_app" "shadowsocks" {
  name                         = "shadowsocks-server"
  container_app_environment_id = azurerm_container_app_environment.vpn_env.id
  resource_group_name          = azurerm_resource_group.vpn_rg.name
  location                     = azurerm_resource_group.vpn_rg.location
  revision_mode                = "Single"

  template {
    min_replicas = 1
    max_replicas = 1

    container {
      name   = "shadowsocks"
      image  = "shadowsocks/shadowsocks-libev:latest"
      cpu    = 0.25
      memory = "0.5Gi"
      env {
        name  = "PASSWORD"
        value = var.shadowsocks_password
      }
      env {
        name  = "METHOD"
        value = var.shadowsocks_method
      }
      #   env {
      #     name  = "PLUGIN"
      #     value = "v2ray-plugin"
      #   }
      #   env {
      #     name  = "PLUGIN_OPTS"
      #     value = var.plugin_opts
      #   }
    }
  }

  ingress {
    external_enabled = true
    target_port      = 8388
    exposed_port     = 443
    transport        = "auto"
    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }

}

variable "shadowsocks_password" {
  description = "Password for Shadowsocks."
  type        = string
}

variable "shadowsocks_method" {
  description = "Encryption method for Shadowsocks."
  type        = string
}

# variable "plugin_opts" {
#   description = "Plugin options for v2ray-plugin."
#   type        = string
# }

# Output the URL of the container app
output "container_app_url" {
  description = "The FQDN (URL) of the Azure Container App."
  value       = azurerm_container_app.shadowsocks.latest_revision_fqdn
}
