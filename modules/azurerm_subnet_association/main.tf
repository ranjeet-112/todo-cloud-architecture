resource "azurerm_subnet_network_security_group_association" "subnet_assoc" {
  for_each = var.subnet_nsg_associations

  subnet_id                 = var.subnet_ids[each.value.virtual_network_key][each.value.subnet_key]
  network_security_group_id = var.nsg_ids[each.value.nsg_key]
  
}


output "assoc_count" {
  value = length(var.subnet_nsg_associations)
}




