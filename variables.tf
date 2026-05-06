variable "subscription_id" {
  type        = string
  description = "Azure Subscription ID where the VNet will be deployed. Used to construct the resource group parent_id for the AVM module."
}

variable "resource_group_name" {
  type        = string
  description = "Name of the existing Resource Group. Pattern: rg-<deptName>-<workload>-<env>-<region>-<instance>."

  validation {
    condition     = can(regex("^rg-[a-z0-9\\-]+$", var.resource_group_name))
    error_message = "resource_group_name must follow the pattern rg-<dept>-<workload>-<env>-<region>-<instance> (all lowercase)."
  }
}

variable "vnet_name" {
  type        = string
  description = "Name of the Virtual Network. Pattern: vnet-<workload>-<env>-<region>-<instance>."

  validation {
    condition     = can(regex("^vnet-[a-z0-9\\-]+$", var.vnet_name))
    error_message = "vnet_name must follow the pattern vnet-<workload>-<env>-<region>-<instance> (all lowercase)."
  }
}

variable "location" {
  type        = string
  description = "Azure region. BDT-MSD approved regions per assumption A2 (FDD §1.3)."
  default     = "eastus2"

  validation {
    condition     = contains(["eastus2", "centralus", "eastus"], var.location)
    error_message = "location must be one of: eastus2, centralus, eastus."
  }
}

variable "address_space" {
  type        = list(string)
  description = "One or more CIDR address spaces for the Virtual Network."

  validation {
    condition     = length(var.address_space) > 0
    error_message = "address_space must contain at least one CIDR block."
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
  description = <<-EOT
    Map of subnet objects. Key = subnet name (pattern: snet-<workload>-<env>-<region>-<instance>).
    Each subnet can optionally reference an existing NSG or Route Table by resource ID.
  EOT
  default = {}
}

variable "hub_vnet_id" {
  type        = string
  description = "Resource ID of the hub VNet to peer with. Leave empty to skip peering."
  default     = ""
}

variable "hub_vnet_name" {
  type        = string
  description = "Name of the hub VNet. Required when hub_vnet_id is set."
  default     = ""
}

variable "enable_resource_lock" {
  type        = bool
  description = "Whether to apply a CanNotDelete lock to the VNet. Recommended for prod environments."
  default     = false
}

variable "log_analytics_workspace_id" {
  type        = string
  description = "Resource ID of the Log Analytics workspace for diagnostic settings. Leave empty to skip."
  default     = ""
}

variable "tags" {
  type        = map(string)
  description = <<-EOT
    Required BDT-MSD tags (FDD Table 12).
    Must include: Application, DevOwner, BusinessOwner, Environment,
                  DataClassification, BusinessCriticality, IACRepository.
    CreationDate is injected automatically by locals.tf.
  EOT

  validation {
    condition = alltrue([
      for k in ["Application", "DevOwner", "BusinessOwner", "Environment",
        "DataClassification", "BusinessCriticality", "IACRepository"] :
      contains(keys(var.tags), k)
    ])
    error_message = "tags must include: Application, DevOwner, BusinessOwner, Environment, DataClassification, BusinessCriticality, IACRepository."
  }
}
