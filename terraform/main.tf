resource "azurerm_resource_group" "rg_python_app" {
  name     = "rg_python_app"
  location = "francecentral"
}

resource "azurerm_virtual_network" "vnet-1" {
  name                = "vnet-1"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg_python_app.location
  resource_group_name = azurerm_resource_group.rg_python_app.name
}

resource "azurerm_subnet" "subnet_1" {
  name                 = "subnet_1"
  resource_group_name  = azurerm_resource_group.rg_python_app.name
  virtual_network_name = azurerm_virtual_network.vnet-1.name
  address_prefixes     = ["10.0.0.0/24"]
}

resource "azurerm_linux_virtual_machine" "vm_app" {
  name                = "vm_app"
  resource_group_name = azurerm_resource_group.rg_python_app.name
  location            = azurerm_resource_group.rg_python_app.location
  size                = "Standard_B1ls"

  network_interface_ids = [azurerm_network_interface.nic_vm_app.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  admin_username                  = "rafiktaamma"
  admin_password                  = "P'''t-UF[PET=Qc"
  disable_password_authentication = false

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}

resource "azurerm_network_interface" "nic_vm_app" {
  name                = "nic_vm_app"
  resource_group_name = azurerm_resource_group.rg_python_app.name
  location            = azurerm_resource_group.rg_python_app.location

  ip_configuration {
    name                          = "config-collab"
    subnet_id                     = azurerm_subnet.subnet_1.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm_app_public_ip.id
  }
}


resource "azurerm_public_ip" "vm_app_public_ip" {
  name                = "vm_app_public_ip"
  resource_group_name = azurerm_resource_group.rg_python_app.name
  location            = azurerm_resource_group.rg_python_app.location
  allocation_method   = "Static"
}