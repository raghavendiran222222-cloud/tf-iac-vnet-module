locals {
  merged_tags = merge(
    var.tags,
    { CreationDate = formatdate("MM/DD/YYYY", timestamp()) }
  )

  resource_group_id = "/subscriptions/${var.subscription_id}/resourceGroups/${var.resource_group_name}"

  create_hub_peering = var.hub_vnet_id != "" && var.hub_vnet_name != ""

  spoke_to_hub_peering_name = local.create_hub_peering ? "peer-${var.vnet_name}-to-${var.hub_vnet_name}" : ""
  hub_to_spoke_peering_name = local.create_hub_peering ? "peer-${var.hub_vnet_name}-to-${var.vnet_name}" : ""

  avm_subnets = {
    for k, v in var.subnets : k => merge(
      {
        name             = k
        address_prefixes = [v.address_prefix]
        service_endpoints_with_location = length(v.service_endpoints) > 0 ? [
          for se in v.service_endpoints : { service = se, locations = ["*"] }
        ] : []
      },
      v.nsg_id != "" ? { network_security_group = { id = v.nsg_id } } : {},
      v.route_table_id != "" ? { route_table = { id = v.route_table_id } } : {},
      v.delegation != null ? {
        delegations = [{
          name               = v.delegation.name
          service_delegation = { name = v.delegation.service }
        }]
      } : {}
    )
  }

  avm_peerings = local.create_hub_peering ? {
    "hub-peering" = {
      name                               = local.spoke_to_hub_peering_name
      remote_virtual_network_resource_id = var.hub_vnet_id
      allow_forwarded_traffic            = true
      allow_virtual_network_access       = true
      allow_gateway_transit              = false
      use_remote_gateways                = true
      create_reverse_peering             = true
      reverse_name                       = local.hub_to_spoke_peering_name
      reverse_allow_forwarded_traffic    = true
      reverse_allow_gateway_transit      = true
      reverse_use_remote_gateways        = false
    }
  } : {}

  lock_config = var.enable_resource_lock ? {
    kind = "CanNotDelete"
    name = "lock-${var.vnet_name}"
  } : null

  diagnostic_settings = var.log_analytics_workspace_id != "" ? {
    "law" = {
      workspace_resource_id = var.log_analytics_workspace_id
    }
  } : {}
}
