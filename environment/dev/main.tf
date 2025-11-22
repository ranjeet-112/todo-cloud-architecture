locals {
    tags = {
        environment = "dev"
        project     = "todo-app"
    }
}

module "rg" {
    source = "../../modules/azurerm_resource_group"
    rgs    = var.rgs
}

module "networking" {
    depends_on       = [module.rg]
    source            = "../../modules/azurerm_networking"
    virtual_networks  = var.virtual_networks
    network_security_groups = var.network_security_groups
    public_ips        = var.public_ips
    bastion_hosts     = var.bastion_hosts
    load_balancers    = var.load_balancers
    tags              = merge(local.tags, var.tags)
}

module "subnet_association" {
    depends_on       = [module.networking]
    source            = "../../modules/azurerm_subnet_association"
    subnet_nsg_associations = var.subnet_nsg_associations
    subnet_ids        = module.networking.subnet_ids
    nsg_ids           = module.networking.nsg_ids
    
}

module "compute" {
    depends_on       = [module.networking]
    source            = "../../modules/azurerm_compute"
    nics              = var.nics
    virtual_machines  = var.virtual_machines
    subnet_ids        = module.networking.subnet_ids
    nsg_ids           = module.networking.nsg_ids
    nic_nsg_associations = var.nic_nsg_associations
    tags              = merge(local.tags, var.tags)
}

  