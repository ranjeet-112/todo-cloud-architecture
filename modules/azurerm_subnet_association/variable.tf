variable "subnet_nsg_associations" {
  type = map(object({
    virtual_network_key = string   # e.g. "dev_vnet"
    subnet_key          = string   # must match subnet.name from vnet (e.g. "frontend-subnet")
    nsg_key             = string   # e.g. "dev_nsg"
  }))
  default = {}
}

variable "subnet_ids" {
  type = map(any)
}

variable "nsg_ids" {
  type = map(string)
}
