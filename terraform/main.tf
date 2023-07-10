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

resource "azurerm_subnet" "subnet-1" {
  name                 = "subnet-1"
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
    name                 = "vm_app_os_disk"
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
    subnet_id                     = azurerm_subnet.subnet-1.id
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

# Ressource to be add . 

resource "azurerm_storage_account" "logs_storage" {
  name                     = "logsstorage${random_integer.random_suffix.result}"
  resource_group_name      = azurerm_resource_group.rg_python_app.name
  location                 = azurerm_resource_group.rg_python_app.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_log_analytics_workspace" "workspace" {
  name                = "python-app-log-analytics-workspace"
  resource_group_name = azurerm_resource_group.rg_python_app.name
  location            = azurerm_resource_group.rg_python_app.location
  sku                 = "PerGB2018"
  retention_in_days   = 7
}


resource "azurerm_monitor_diagnostic_setting" "vm_app_diagnostic" {
  name               = "vm-app-diagnostic"
  target_resource_id = azurerm_linux_virtual_machine.vm_app.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.workspace.id

  log {
    category = "Metrics"
    enabled  = true
  }

  log {
    category = "Diagnostics"
    enabled  = true
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}

resource "azurerm_log_analytics_linked_storage_account" "logs_export" {
  data_source_type      = "customlogs"
  resource_group_name   = azurerm_resource_group.rg_python_app.name
  workspace_resource_id = azurerm_log_analytics_workspace.workspace.id
  storage_account_ids   = [azurerm_storage_account.logs_storage.id]

  depends_on = [azurerm_log_analytics_workspace.workspace, azurerm_storage_account.logs_storage]
}


resource "azurerm_log_analytics_data_export_rule" "logs_export_rule" {
  name                    = "logsExportRule"
  resource_group_name     = azurerm_resource_group.rg_python_app.name
  workspace_resource_id   = azurerm_log_analytics_workspace.workspace.id
  enabled                 = true
  destination_resource_id = azurerm_storage_account.logs_storage.id
  table_names             = ["Heartbeat","Usage"] # A list of table names to export to the destination resource, for example: ["Heartbeat", "SecurityEvent"]
  # retention_enabled       = true
  # retention_days          = 365 # Update with the desired retention period in days
}

## Adding Metric alert and action group to send an email . 