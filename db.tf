resource "azurerm_network_interface" "ni_db" {
  name                = "ni-db"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal-db"
    subnet_id                     = azurerm_subnet.db.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "db_vm" {
  name                  = "dbServer-${azurerm_resource_group.rg.name}"
  resource_group_name   = azurerm_resource_group.rg.name
  location              = azurerm_resource_group.rg.location
  size                  = var.vm-sku
  admin_username = "adminuser"

  admin_ssh_key {
    username = "adminuser"
    public_key = file("~/.ssh/db-server.pub")
  }
  network_interface_ids = [azurerm_network_interface.ni_db.id]

  

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
}

resource "random_string" "storage_account_name" {
  length  = 24
  special = false
  upper   = false
  numeric  = true
}


resource "azurerm_storage_account" "st" {
  name                     = random_string.storage_account_name.result
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_kind             = "BlobStorage"
  account_tier             = "Standard"
  access_tier              = "Cool"
  account_replication_type = "LRS"

  tags = {
    environment = "${azurerm_resource_group.rg.name}"
  }
}

resource "azurerm_managed_disk" "db_disk" {
  name                 = "db_disk-${azurerm_resource_group.rg.name}"
  location             = azurerm_resource_group.rg.location
  resource_group_name  = azurerm_resource_group.rg.name
  storage_account_type = "Standard_LRS"
  storage_account_id   = azurerm_storage_account.st.id
  create_option        = "Empty"
  disk_size_gb         = "1"

  tags = {
    environment = "${azurerm_resource_group.rg.name}"
  }
}

resource "azurerm_virtual_machine_data_disk_attachment" "db_disk-attachment" {
  managed_disk_id    = azurerm_managed_disk.db_disk.id
  virtual_machine_id = azurerm_linux_virtual_machine.db_vm.id
  lun                = "10"
  caching            = "ReadWrite"
}