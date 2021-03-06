resource "azurerm_virtual_machine" "tf-manager-vm" {
  count = "${var.numberOfManagers}"

  name                = "manager-vm-${count.index}"
  location            = "${azurerm_resource_group.tf-swarm-cluster-resourcegroup.location}"
  resource_group_name = "${azurerm_resource_group.tf-swarm-cluster-resourcegroup.name}"

  network_interface_ids = ["${azurerm_network_interface.tf-manager-nic.*.id[count.index]}"]
  availability_set_id   = "${azurerm_availability_set.tf-managers-availability-set.id}"

  vm_size = "${var.managerVmSize}"

  delete_os_disk_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "${var.ubuntuVersion}"
    version   = "latest"
  }

  storage_os_disk {
    name              = "manager-vm-os-disk-${count.index}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "manager-${count.index + 1}"
    admin_username = "${var.userName}"
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      path     = "/home/${var.userName}/.ssh/authorized_keys"
      key_data = "${file("${path.module}/ssh/manager-rsa.pub")}"
    }
  }

  tags {
    environment = "${var.env}"
  }
}
