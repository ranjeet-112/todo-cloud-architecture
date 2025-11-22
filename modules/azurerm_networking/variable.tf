# Virtual Networks
variable "virtual_networks" {
  type = map(object({
    name                = string
    location            = string
    resource_group_name = string
    address_space       = list(string)
    dns_servers         = optional(list(string))
    subnets = optional(map(object({
      name             = string
      address_prefixes = list(string)
    })))
    tags = optional(map(string))
  }))
  default = {}
}

# Network Security Groups
variable "network_security_groups" {
  type = map(object({
    name                = string
    location            = string
    resource_group_name = string
    security_rules = optional(map(object({
      name                       = string
      priority                   = number
      direction                  = string
      access                     = string
      protocol                   = string
      source_port_range          = string
      destination_port_range     = string
      source_address_prefix      = string
      destination_address_prefix = string
    })))
    tags = optional(map(string))
  }))
  default = {}
}

# Public IPs
variable "public_ips" {
  type = map(object({
    name                = string
    location            = string
    resource_group_name = string
    allocation_method   = string
    sku                 = string
    tags                = optional(map(string))
  }))
  default = {}
}

variable "tags" {
  type = map(string)
  default = {}
}

# Bastion Hosts
variable "bastion_hosts" {
  type = map(object({
    name                = string
    location            = string
    resource_group_name = string
    sku                 = string
    ip_configuration = object({
      name                 = string
      subnet_name          = string
      vnet_name            = string
      public_ip_key        = string
    })
    tags = optional(map(string))
  }))
  default = {}
}

# Load Balancers
variable "load_balancers" {
  type = map(object({
    name                = string
    location            = string
    resource_group_name = string
    sku                 = string

    frontend_ip_configuration = object({
      name                          = string
      vnet_key                      = string  # (key of virtual_networks map)
      subnet_key                    = string  # (must match subnet.name in virtual_networks)
      private_ip_address_allocation = string
    })

    tags = optional(map(string), {})
  }))
  default = {}
}


