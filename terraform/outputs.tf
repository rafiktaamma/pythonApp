output "vm_public_ip" {
  value = azurerm_linux_virtual_machine.vm_app.public_ip_address
}

output "nic_public_ip" {
  value = azurerm_public_ip.vm_app_public_ip.ip_address

}

output "vm_username" {
  value = azurerm_linux_virtual_machine.vm_app.admin_username
}

output "vm_password" {
  value     = azurerm_linux_virtual_machine.vm_app.admin_password
  sensitive = true
}
