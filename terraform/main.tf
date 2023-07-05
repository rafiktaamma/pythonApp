resource "azurerm_resource_group" "rg_collab_rt" {
  name     = "rg-collab-rt"
  location = "francecentral"
}

resource "azurerm_virtual_network" "vnet_collab" {
  name                = "vnet-collab"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg_collab_rt.location
  resource_group_name = azurerm_resource_group.rg_collab_rt.name
}

resource "azurerm_subnet" "subnet_collab" {
  name                 = "subnet-collab"
  resource_group_name  = azurerm_resource_group.rg_collab_rt.name
  virtual_network_name = azurerm_virtual_network.vnet_collab.name
  address_prefixes     = ["10.0.0.0/24"]
}

resource "azurerm_linux_virtual_machine" "vm_collab" {
  name                = "vm-collab"
  resource_group_name = azurerm_resource_group.rg_collab_rt.name
  location            = azurerm_resource_group.rg_collab_rt.location
  size                = "Standard_B1ls"

  network_interface_ids = [azurerm_network_interface.nic_collab.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  admin_username                  = "rafiktaamma"
  admin_password                  = "brahim09@"
  disable_password_authentication = false

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}

resource "azurerm_network_interface" "nic_collab" {
  name                = "nic-collab"
  resource_group_name = azurerm_resource_group.rg_collab_rt.name
  location            = azurerm_resource_group.rg_collab_rt.location

  ip_configuration {
    name                          = "config-collab"
    subnet_id                     = azurerm_subnet.subnet_collab.id
    private_ip_address_allocation = "Dynamic"
  }
}
