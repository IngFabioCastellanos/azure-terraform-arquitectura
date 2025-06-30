/* prerequisitos:
  1. Azure CLI installed and configured
  2. Terraform installed (open tofu)
  3. Azure subscription with permissions to create resources
  4. Ensure the Azure provider is authenticated (az login)
 */


terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "4.32.0"
    }
  }
}

provider "azurerm" {
  features {
  }
  subscription_id = "3cdd48da-6171-4483-8b53-f2783c01f2cf"
}

resource "azurerm_resource_group" "rg-example" {
  name     = "rg-dev-webapp-eastus"
  location = "eastus"
  tags = {
    environment = "development"
    project     = "webapp"
    owner       = "devops-team"
    cost_center = "12345"
  }

}


# ------------- Recursos de Red - Video 2 - VNet, Subnets, NSG  ------------- #

  # Definimos el recurso de Red Virtual (VNet)
  resource "azurerm_virtual_network" "main_vnet" {
    name                = "vnet-dev-webapp-eastus"
    address_space       = ["10.0.0.0/16"]
    location            = azurerm_resource_group.rg-example.location
    resource_group_name = azurerm_resource_group.rg-example.name

    tags = {
      environment = "dev"
      project     = "webapp"
      owner       = "tu_equipo"
    }
  }

  # Definimos la primera subred (ej. para web)
  resource "azurerm_subnet" "web_subnet" {
    name                 = "subnet-web"
    resource_group_name  = azurerm_resource_group.rg-example.name
    virtual_network_name = azurerm_virtual_network.main_vnet.name
    address_prefixes     = ["10.0.1.0/24"]
  }

  # Definimos la segunda subred (ej. para base de datos)
  resource "azurerm_subnet" "db_subnet" {
    name                 = "subnet-db"
    resource_group_name  = azurerm_resource_group.rg-example.name
    virtual_network_name = azurerm_virtual_network.main_vnet.name
    address_prefixes     = ["10.0.2.0/24"]
  }

  # Definimos un Network Security Group (NSG) para la subred web
  resource "azurerm_network_security_group" "web_nsg" {
    name                = "nsg-web-inbound"
    location            = azurerm_resource_group.rg-example.location
    resource_group_name = azurerm_resource_group.rg-example.name

    security_rule {
      name                       = "AllowHTTP"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "80"
      source_address_prefix      = "Internet"
      destination_address_prefix = "*"
    }

    security_rule {
      name                       = "AllowHTTPS"
      priority                   = 110
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "443"
      source_address_prefix      = "Internet"
      destination_address_prefix = "*"
    }

    security_rule {
      name                       = "DenyAllOtherInbound"
      priority                   = 4096
      direction                  = "Inbound"
      access                     = "Deny"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
  }

  # Asociar el NSG a la subred web
  resource "azurerm_subnet_network_security_group_association" "web_nsg_association" {
    subnet_id                 = azurerm_subnet.web_subnet.id
    network_security_group_id = azurerm_network_security_group.web_nsg.id
  }