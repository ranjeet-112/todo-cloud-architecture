# subnet IDs
output "subnet_ids" {
  value = {
    for vnet_key, vnet in azurerm_virtual_network.dev_vnet :
    vnet_key => {
      for subnet in vnet.subnet :
      subnet.name => subnet.id
    }
  }
  description = "Map: vnet_key -> (subnet_name -> subnet_id)"
}

# Network Security Group
output "nsg_ids" {
  value = { for nsg_key, nsg in azurerm_network_security_group.dev_nsg : nsg_key => nsg.id }
  description = "Map of nsg_key -> nsg_id"
}

# Public IP
output "public_ip_ids" {
  value = { for pip_key, pip in azurerm_public_ip.dev_pip : pip_key => pip.id }
  description = "Map of public ip key -> id"
}

# Load Balancer
output "load_balancer_ids" {
  value = { for k, v in azurerm_lb.dev_lb : k => v.id }
}
