output "nic_ids" {
  value = { for nic_key, nic in azurerm_network_interface.dev_nic : nic_key => nic.id }
}

output "vm_ids" {
  value = { for vm_key, vm in azurerm_linux_virtual_machine.dev_vm : vm_key => vm.id }
}

