variable "subscription_id" {
  type        = string
  sensitive   = true
  default     = "00000000-0000-0000-0000-000000000000"
  description = "Azure Subscription ID."
}

variable "resource_group_name" {
  type        = string
  default     = "rg-myapp-dev-eus2-001"
  description = "Name of the pre-existing Resource Group."
}

variable "vnet_name" {
  type        = string
  default     = "vnet-myapp-dev-eus2-001"
  description = "Name of the Virtual Network."
}

variable "location" {
  type        = string
  default     = "eastus2"
  description = "Azure region."
}

variable "address_space" {
  type        = list(string)
  default     = ["10.10.0.0/16"]
  description = "VNet address space."
}
