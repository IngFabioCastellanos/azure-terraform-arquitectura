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
