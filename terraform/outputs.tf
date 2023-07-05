output "vm_public_ip" {
  value = azurerm_linux_virtual_machine.vm_collab.public_ip_address
}

output "vm_username" {
  value = azurerm_linux_virtual_machine.vm_collab.admin_username
}

output "vm_password" {
  value     = azurerm_linux_virtual_machine.vm_collab.admin_password
  sensitive = true
}
