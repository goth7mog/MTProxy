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

data "azurerm_client_config" "current" {}

# Resource Group
resource "azurerm_resource_group" "vpn_rg" {
  name     = "shadowsocks-rg"
  location = "switzerlandnorth"
}



# Reference existing Resource Group from previous project
data "azurerm_resource_group" "sce_rg" {
  name = "sce-rg" # Update this to the actual name of your previous resource group if different
}

# Reference existing Container App Environment from previous project
data "azurerm_container_app_environment" "vpn_env" {
  name                = "sce-env"
  resource_group_name = data.azurerm_resource_group.sce_rg.name
}



# Container Instance for Shadowsocks
resource "azurerm_container_group" "shadowsocks" {
  name                = "shadowsocks-server"
  location            = azurerm_resource_group.vpn_rg.location
  resource_group_name = azurerm_resource_group.vpn_rg.name
  os_type             = "Linux"


  container {
    name   = "shadowsocks"
    image  = "shadowsocks/shadowsocks-libev:latest"
    cpu    = 0.25
    memory = 0.5
    environment_variables = {
      PASSWORD = var.shadowsocks_password
      METHOD   = var.shadowsocks_method
      # Uncomment and set if needed:
      # PLUGIN = "v2ray-plugin"
      # PLUGIN_OPTS = var.plugin_opts
    }
    ports {
      port = 8388
    }
  }


  ip_address_type = "Public"
  dns_name_label  = "shadowsocks-${random_string.dns.result}"
}

# Random string for DNS label
resource "random_string" "dns" {
  length  = 6
  upper   = false
  special = false
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


# Output the FQDN and IP of the Container Instance
output "container_instance_fqdn" {
  description = "The FQDN (URL) of the Azure Container Instance."
  value       = azurerm_container_group.shadowsocks.fqdn
}

output "container_instance_ip" {
  description = "The public IP address of the Azure Container Instance."
  value       = azurerm_container_group.shadowsocks.ip_address
}
