terraform {
  backend "azurerm" {
    resource_group_name  = "rg-collab-rt"
    storage_account_name = "terraformblob9350"
    container_name       = "tfstate"
    key                  = "prod.terraform.tfstate"
    #     access_key = var.access_key
  }
}
