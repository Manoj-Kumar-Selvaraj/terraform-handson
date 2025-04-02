provider "azurerm" {
  features {}
  skip_provider_registration = true
  storage_use_azuread = true
}

data "azurerm_resource_group" "main" {
  name = var.resource_group_name
}

resource "random_integer" "main" {
  min = 100000
  max = 999999
}

resource "azurerm_storage_account" "main" {
  name                     = "${var.storage_account_name}${random_integer.main.result}"
  resource_group_name      = data.azurerm_resource_group.main.name
  location                 = data.azurerm_resource_group.main.location
  account_tier             = var.account_tier
  account_replication_type = var.account_replication_type
  account_kind             = var.account_kind

  min_tls_version                    = "TLS1_2"
  allow_nested_items_to_be_public    = false
  large_file_share_enabled           = true
  shared_access_key_enabled          = false
  default_to_oauth_authentication    = true
  infrastructure_encryption_enabled  = false
  https_traffic_only_enabled         = true

  blob_properties {
    versioning_enabled              = true
    last_access_time_enabled        = true
    change_feed_enabled             = true
    change_feed_retention_in_days   = 60
    delete_retention_policy {
        days = 30
    }
    container_delete_retention_policy {
        days = 30
    }
  }

  sas_policy {
    expiration_period = "00.02:00:00"
    expiration_action = "Log"
  }

  timeouts {
    create = "5m"
    read   = "5m"
  }
}

# Create a storage container for Terraform state
resource "azurerm_storage_container" "main" {
  name                  = "tfstate"
  storage_account_name  = azurerm_storage_account.main.name
  container_access_type = "private"
}

# Create an empty Terraform state file (blob)
resource "azurerm_storage_blob" "tfstate" {
  name                   = "terraform.tfstate"
  storage_account_name   = azurerm_storage_account.main.name
  storage_container_name = azurerm_storage_container.main.name
  type                   = "Block"
  source                 = "empty.tfstate"
}
