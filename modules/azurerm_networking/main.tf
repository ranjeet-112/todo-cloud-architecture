# Virtual Network
resource "azurerm_virtual_network" "dev_vnet" {
  for_each            = var.virtual_networks
  name                = each.value.name
  location            = each.value.location
  resource_group_name = each.value.resource_group_name
  address_space       = each.value.address_space
  dns_servers         = try(each.value.dns_servers, null)

  dynamic "subnet" {
    for_each = tomap(try(each.value.subnets, {}))
    content {
      name             = subnet.value.name
      address_prefixes = subnet.value.address_prefixes
    }
  }

  tags = merge(var.tags, try(each.value.tags, {}))
}

# Network Security Group
resource "azurerm_network_security_group" "dev_nsg" {
  for_each = var.network_security_groups

  name                = each.value.name
  location            = each.value.location
  resource_group_name = each.value.resource_group_name

  dynamic "security_rule" {
    for_each = tomap(try(each.value.security_rules, {}))
    content {
      name                       = security_rule.value.name
      priority                   = security_rule.value.priority
      direction                  = security_rule.value.direction
      access                     = security_rule.value.access
      protocol                   = security_rule.value.protocol
      source_port_range          = security_rule.value.source_port_range
      destination_port_range     = security_rule.value.destination_port_range
      source_address_prefix      = security_rule.value.source_address_prefix
      destination_address_prefix = security_rule.value.destination_address_prefix
    }
  }

  tags = merge(var.tags, try(each.value.tags, {}))
}

# Public IP
resource "azurerm_public_ip" "dev_pip" {
  for_each            = var.public_ips
  name                = each.value.name
  location            = each.value.location
  resource_group_name = each.value.resource_group_name
  allocation_method   = each.value.allocation_method
  sku                 = each.value.sku
  tags                = try(each.value.tags, {})
}

# Bastion Host
resource "azurerm_bastion_host" "dev_bastion" {
  for_each            = var.bastion_hosts
  name                = each.value.name
  location            = each.value.location
  resource_group_name = each.value.resource_group_name
  sku                 = each.value.sku

  ip_configuration {
    name = each.value.ip_configuration.name

    subnet_id = one([
  for s in azurerm_virtual_network.dev_vnet[each.value.ip_configuration.vnet_name].subnet :
  s.id if s.name == each.value.ip_configuration.subnet_name
])                                                          
#  for s in ...subnet : s.id if s.name == ...(ye loop har subnet object check karta hai.)
#  if s.name == each.value.ip_configuration.subnet_name ...ye condition lagata hai ki sirf wahi subnet id le jo subnet_name ke barabar ho.

    public_ip_address_id = azurerm_public_ip.dev_pip[
      each.value.ip_configuration.public_ip_key
    ].id
  }

  tags = merge(var.tags, try(each.value.tags, {}))
}

# Load Balancer
resource "azurerm_lb" "dev_lb" {
  for_each            = var.load_balancers
  name                = each.value.name
  location            = each.value.location
  resource_group_name = each.value.resource_group_name
  sku                 = each.value.sku
  tags                = try(each.value.tags, {})

  frontend_ip_configuration {
    name = each.value.frontend_ip_configuration.name

    # Resolve subnet id from the VNet's subnets (subnet.name -> id mapping)
    subnet_id = one([
      for s in azurerm_virtual_network.dev_vnet[
        each.value.frontend_ip_configuration.vnet_key
      ].subnet : s.id if s.name == each.value.frontend_ip_configuration.subnet_key
    ])

    private_ip_address_allocation = each.value.frontend_ip_configuration.private_ip_address_allocation
  }
}

# Backend Address Pool
resource "azurerm_lb_backend_address_pool" "backend_pool" {
  for_each            = var.load_balancers
  name                = "${each.value.name}-bepool"
  loadbalancer_id     = azurerm_lb.dev_lb[each.key].id
}

# Health Probe
resource "azurerm_lb_probe" "health_probe" {
  for_each            = var.load_balancers
  name                = "${each.value.name}-healthprobe"
  loadbalancer_id     = azurerm_lb.dev_lb[each.key].id
  protocol            = "Tcp"
  port                = 80
  interval_in_seconds = 5
  number_of_probes    = 2
}

# Load Balancing Rule
resource "azurerm_lb_rule" "lb_rule" {
  for_each                        = var.load_balancers
  name                            = "${each.value.name}-lbrule"
  loadbalancer_id                 = azurerm_lb.dev_lb[each.key].id
  protocol                        = "Tcp"
  frontend_port                   = 80
  backend_port                    = 80
  frontend_ip_configuration_name  = each.value.frontend_ip_configuration.name
  backend_address_pool_ids        = [azurerm_lb_backend_address_pool.backend_pool[each.key].id]
  probe_id                        = azurerm_lb_probe.health_probe[each.key].id
}

