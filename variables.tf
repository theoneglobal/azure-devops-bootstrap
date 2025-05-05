variable "resource_group_name" {
  description = "Name of the Azure Resource Group"
  type        = string
}

variable "location" {
  description = "Azure Region"
  type        = string
  default     = "West Europe"
}

variable "storage_account_name" {
  description = "Globally unique name for the Azure Storage Account (3-24 lowercase letters/digits)"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]{3,24}$", var.storage_account_name))
    error_message = "Storage account name must be 3-24 lowercase alphanumeric characters only."
  }
}

variable "container_name" {
  description = "Blob container name for Terraform state"
  type        = string
}
