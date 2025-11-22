variable "rgs" {
  type = map(object({
  name       = string
  location   = string
  managed_by = optional(string)
  tags       = map(string)
    }))
}


variable "virtual_networks" { type = map(any) }
variable "network_security_groups" { type = map(any) }
variable "subnet_nsg_associations" { type = map(any) }
variable "public_ips" { type = map(any) }
variable "nics" { type = map(any) }
variable "nic_nsg_associations" { type = map(any) }
variable "virtual_machines" { type = map(any) }
variable "tags" {
  type    = map(string)
  default = {}
}

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



