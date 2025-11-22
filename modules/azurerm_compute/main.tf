resource "azurerm_network_interface" "dev_nic" {
  for_each = var.nics

  name                = each.value.name
  location            = each.value.location
  resource_group_name = each.value.resource_group_name

  dynamic "ip_configuration" {
    for_each = each.value.ip_configurations
    content {
      name                          = ip_configuration.value.name

      subnet_id = var.subnet_ids[each.value.virtual_network_key][
        ip_configuration.value.subnet_key
      ]

      private_ip_address_allocation = ip_configuration.value.private_ip_address_allocation

      public_ip_address_id = (
        ip_configuration.value.public_ip_key != null &&
        contains(keys(var.public_ip_ids), ip_configuration.value.public_ip_key)
      ) ? var.public_ip_ids[ip_configuration.value.public_ip_key] : null
    }
  }

  tags = merge(var.tags, try(each.value.tags, {}))
}




resource "azurerm_network_interface_security_group_association" "nic_assoc" {
  for_each = var.nic_nsg_associations

  network_interface_id      = azurerm_network_interface.dev_nic[each.value.nic_key].id
  network_security_group_id = var.nsg_ids[each.value.nsg_key]
}


resource "azurerm_linux_virtual_machine" "dev_vm" {
  for_each = var.virtual_machines

  name                = each.value.name
  location            = each.value.location
  resource_group_name = each.value.resource_group_name
  size                = each.value.size
  admin_username      = each.value.admin_username
  custom_data         = each.value.script_name != "" ? base64encode(file(each.value.script_name)) : null

  network_interface_ids = [
    azurerm_network_interface.dev_nic[each.value.network_interface_key].id
  ]

  admin_ssh_key {
    username   = each.value.admin_username
    public_key = file(pathexpand(each.value.admin_ssh_key))
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = each.value.image.publisher
    offer     = each.value.image.offer
    sku       = each.value.image.sku
    version   = each.value.image.version
  }

  disable_password_authentication = true

  tags = merge(var.tags, try(each.value.tags, {}))
}





