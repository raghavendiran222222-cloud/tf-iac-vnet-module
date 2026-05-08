locals {
  resource_group_id = "/subscriptions/${var.subscription_id}/resourceGroups/${var.resource_group_name}"

  merged_tags = merge(var.tags, {
    ManagedBy   = "Terraform"
    CreatedDate = formatdate("YYYY-MM-DD", timestamp())
  })

  create_hub_peering = var.hub_vnet_id != "" && var.hub_vnet_name != ""

  avm_subnets = {
    for name, subnet in var.subnets : name => {
      name             = name
      address_prefixes = [subnet.address_prefix]

      service_endpoints_with_location = length(subnet.service_endpoints) > 0 ? [
        for ep in subnet.service_endpoints : {
          service   = ep
          locations = ["*"]
        }
      ] : null

      network_security_group = subnet.nsg_id != "" ? { id = subnet.nsg_id } : null
      route_table            = subnet.route_table_id != "" ? { id = subnet.route_table_id } : null

      delegations = subnet.delegation != null ? [
        {
          name = subnet.delegation.name
          service_delegation = {
            name = subnet.delegation.service
          }
        }
      ] : null
    }
  }

  spoke_to_hub_peering_name = "peer-${var.vnet_name}-to-${var.hub_vnet_name}"
  hub_to_spoke_peering_name = "peer-${var.hub_vnet_name}-to-${var.vnet_name}"

  avm_peerings = local.create_hub_peering ? {
    (local.spoke_to_hub_peering_name) = {
      name                               = local.spoke_to_hub_peering_name
      remote_virtual_network_resource_id = var.hub_vnet_id
      allow_forwarded_traffic            = true
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

  ddos_protection_plan = var.ddos_protection_plan_id != "" ? {
    id     = var.ddos_protection_plan_id
    enable = true
  } : null

  dns_servers_config = length(var.dns_servers) > 0 ? {
    dns_servers = var.dns_servers
  } : null
}
