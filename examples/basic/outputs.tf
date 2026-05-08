output "vnet_id" {
  description = "Resource ID of the Virtual Network."
  value       = module.spoke_vnet.vnet_id
}

output "vnet_name" {
  description = "Name of the Virtual Network."
  value       = module.spoke_vnet.vnet_name
}

output "subnet_ids" {
  description = "Map of subnet name to subnet resource ID."
  value       = module.spoke_vnet.subnet_ids
}
