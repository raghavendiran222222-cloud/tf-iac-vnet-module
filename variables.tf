variable "subscription_id" {
  type        = string
  sensitive   = true
  description = "Azure Subscription ID where the Virtual Network will be deployed."
}

variable "resource_group_name" {
  type        = string
  description = "Name of the pre-existing Resource Group to deploy the Virtual Network into."
}

variable "vnet_name" {
  type        = string
  description = "Name of the Virtual Network."
}

variable "location" {
  type        = string
  default     = "eastus2"
  description = "Azure region for the Virtual Network."

  validation {
    condition     = contains(["eastus2", "centralus", "eastus", "westus2", "westeurope", "northeurope"], var.location)
    error_message = "location must be one of: eastus2, centralus, eastus, westus2, westeurope, northeurope."
  }
}

variable "address_space" {
  type        = list(string)
  description = "List of CIDR address spaces for the Virtual Network. Must contain at least one entry."

  validation {
    condition     = length(var.address_space) >= 1
    error_message = "address_space must contain at least one CIDR block."
  }
}

variable "tags" {
  type        = map(string)
  description = "Map of tags to apply to all resources. Required keys: Application, Owner, Environment, CostCenter."

  validation {
    condition = alltrue([
      contains(keys(var.tags), "Application"),
      contains(keys(var.tags), "Owner"),
      contains(keys(var.tags), "Environment"),
      contains(keys(var.tags), "CostCenter"),
    ])
    error_message = "tags must include: Application, Owner, Environment, CostCenter."
  }
}

variable "subnets" {
  type = map(object({
    address_prefix    = string
    service_endpoints = optional(list(string), [])
    nsg_id            = optional(string, "")
    route_table_id    = optional(string, "")
    delegation = optional(object({
      name    = string
      service = string
    }), null)
  }))
  default     = {}
  description = "Map of subnet configurations keyed by subnet name."
}

variable "dns_servers" {
  type        = list(string)
  default     = []
  description = "List of custom DNS server IP addresses. Leave empty to use Azure default DNS."
}

variable "ddos_protection_plan_id" {
  type        = string
  default     = ""
  description = "Resource ID of an existing DDoS Protection Plan. Leave empty to skip DDoS protection."
}

variable "hub_vnet_id" {
  type        = string
  default     = ""
  description = "Resource ID of the hub Virtual Network for hub-spoke peering. Both hub_vnet_id and hub_vnet_name must be set to enable peering."
}

variable "hub_vnet_name" {
  type        = string
  default     = ""
  description = "Name of the hub Virtual Network. Required when hub_vnet_id is set."
}

variable "enable_resource_lock" {
  type        = bool
  default     = false
  description = "When true, applies a CanNotDelete lock to the Virtual Network. Recommended for production environments."
}

variable "log_analytics_workspace_id" {
  type        = string
  default     = ""
  description = "Resource ID of a Log Analytics Workspace for diagnostic settings. Leave empty to skip diagnostics."
}
