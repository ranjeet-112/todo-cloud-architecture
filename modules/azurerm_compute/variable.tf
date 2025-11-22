variable "nics" {
  type = map(object({
    name                = string
    location            = string
    resource_group_name = string
    virtual_network_key = string
    ip_configurations   = map(object({
      name                          = string
      subnet_key                    = string
      private_ip_address_allocation = string
      public_ip_key                 = optional(string)
    }))
    tags = optional(map(string), {})
  }))
  default = {}
}

variable "virtual_machines" {
  type = map(object({
    name                  = string
    location              = string
    resource_group_name   = string
    size                  = string
    admin_username        = string
    admin_ssh_key         = string
    script_name           = optional(string, "")
    network_interface_key = string
    image = object({
      publisher = string
      offer     = string
      sku       = string
      version   = string
    })
    tags = optional(map(string), {})
  }))
  default = {}
}

variable "subnet_ids" {
  type = map(any)
}

variable "public_ip_ids" {
  type = map(string)
  default = {}
}

variable "nsg_ids" {
  type = map(string)
}

variable "nic_nsg_associations" {
  type = map(object({
    nic_key = string
    nsg_key = string
  }))
  default = {}
}

variable "tags" {
  type = map(string)
  default = {}
}
