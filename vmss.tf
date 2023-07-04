resource "azurerm_linux_virtual_machine_scale_set" "vmss-medibot" {
  name                = "vmss-medibot"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = var.vm-sku
  instances           = 5
  admin_username      = "adminuser"

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/vmss.pub")
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  network_interface {
    name    = "ni-vmss-${azurerm_resource_group.rg.name}"
    primary = true

    ip_configuration {
      name                                   = "vmss-ip_config"
      primary                                = true
      subnet_id                              = azurerm_subnet.web.id
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.lb-bap.id]
    }
  }
}
