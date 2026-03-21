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
  subscription_id = var.subscription_id
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


# Container Instance for Shadowsocks
resource "azurerm_container_group" "shadowsocks" {
  name                = "shadowsocks-server"
  location            = data.azurerm_resource_group.sce_rg.location
  resource_group_name = data.azurerm_resource_group.sce_rg.name
  os_type             = "Linux"

  container {
    name   = "shadowsocks"
    image  = "${var.acr_name}.azurecr.io/shadowsocks:latest"
    cpu    = 0.25
    memory = 0.5
    environment_variables = {
      SHADOWSOCKS_PASSWORD = var.shadowsocks_password
      SHADOWSOCKS_METHOD   = var.shadowsocks_method
      SHADOWSOCKS_PORT     = var.shadowsocks_port
    }
    ports {
      port = var.shadowsocks_port
    }
  }

  ip_address_type = "Public"
  dns_name_label  = "shadowsocks${random_string.dns.result}"

  image_registry_credential {
    server   = "${var.acr_name}.azurecr.io"
    username = var.acr_username
    password = var.acr_password
  }
}


# Nginx container to proxy 443 -> Shadowsocks-server:8388
resource "azurerm_container_group" "nginx_proxy" {
  name                = "nginx-proxy"
  location            = data.azurerm_resource_group.sce_rg.location
  resource_group_name = data.azurerm_resource_group.sce_rg.name
  os_type             = "Linux"

  container {
    name   = "nginx"
    image  = "${var.acr_name}.azurecr.io/nginx-proxy:latest"
    cpu    = 0.25
    memory = 0.5

    ports {
      port = 443
    }
  }

  image_registry_credential {
    server   = "${var.acr_name}.azurecr.io"
    username = var.acr_username
    password = var.acr_password
  }

  ip_address_type = "Public"
}



# Random string for DNS label
resource "random_string" "dns" {
  length  = 6
  upper   = false
  special = false
}


# New variables for subscription_id and acr_name
variable "subscription_id" {
  description = "Azure Subscription ID."
  type        = string
}

variable "acr_name" {
  description = "Azure Container Registry name (without .azurecr.io)."
  type        = string
}


variable "shadowsocks_password" {
  description = "Password for Shadowsocks."
  type        = string
}

variable "shadowsocks_method" {
  description = "Encryption method for Shadowsocks."
  type        = string
}

variable "shadowsocks_port" {
  description = "Port for Shadowsocks."
  type        = number
  default     = 8388
}

variable "acr_username" {
  description = "ACR registry username."
  type        = string
}

variable "acr_password" {
  description = "ACR registry password."
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

# Output the public IP address of the nginx_proxy Container Instance
output "nginx_proxy_ip" {
  description = "The public IP address of the nginx proxy Container Instance."
  value       = azurerm_container_group.nginx_proxy.ip_address
}
