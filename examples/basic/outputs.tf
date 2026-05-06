output "vnet_id"     { value = module.spoke_vnet.vnet_id }
output "vnet_name"   { value = module.spoke_vnet.vnet_name }
output "subnet_ids"  { value = module.spoke_vnet.subnet_ids }
output "peerings"    { value = module.spoke_vnet.peerings }
