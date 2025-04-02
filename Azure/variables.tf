variable "resource_group_name" {
    description = "The name of the resource group in which to create the storage account."
    type        = string
}

variable "account_tier" {
    description = "The performance tier of the storage account."
    type        = string
    default     = "Standard"
}   

variable "account_replication_type" {
    description = "The replication type of the storage account."
    type        = string
    default     = "GRS"
}   

variable "account_kind" {
    description = "The kind of the storage account."
    type        = string
    default     = "StorageV2"
}
variable "storage_account_name" {
    description = "The name of the storage account."
    type        = string
}
variable "tags" {
    description = "A map of tags to assign to the storage account."
    type        = map(string)
    default     = {}
}


