terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>2.0"
    }
  }
}

provider "azurerm" {
  features {}

  subscription_id = "02506eb6-f44a-4256-9724-fafebc2fce46"
  tenant_id       = "6f44c34c-2551-43d8-b05d-29941871d904"
  client_id       = "23e90616-1ae9-4a8c-a291-a6ce7eb25dac"
  client_secret   = "4nk8Q~zBjs41GpPMy~Z9fTLDLuafHcpnkVCTDdgy"
}

# Your code goes here