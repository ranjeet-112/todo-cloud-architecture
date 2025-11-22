terraform {
    backend "azurerm" {
        resource_group_name  = "ran_rg"
        storage_account_name = "ranjeetsingh112"
        container_name       = "ranjeetcontainer"
        key                  = "dev.terraform.tfstate"
    }
    required_providers {
        azurerm = {
            source  = "hashicorp/azurerm"
            version = ">=3.80.0"
        }
    }
}
provider "azurerm" {
    features {
        api_management {
            purge_soft_delete_on_destroy = true
            recover_soft_deleted         = true
        }
        app_configuration {
           purge_soft_delete_on_destroy = true
           recover_soft_deleted         = true
    }
    }
    subscription_id = "85002d33-efb7-4e6a-8e6d-7457837654e2"
}