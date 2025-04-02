#CALLING STORAGE MODULE
module "storage" {
  source = "./modules/Storage"
  storage_account_name = var.storage_account_name
  resource_group_name  = var.resource_group_name
  account_tier         = var.account_tier
  account_replication_type = var.account_replication_type
  account_kind        = var.account_kind
  tags                = var.tags
}

