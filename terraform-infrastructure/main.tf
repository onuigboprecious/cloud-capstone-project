resource "azurerm_resource_group" "formflow" {
  name     = "rg-formflow-${var.environment}"
  location = var.location
}

resource "azurerm_virtual_network" "formflow" {
  name                = "vnet-formflow"
  address_space       = ["10.10.0.0/16"]
  location            = azurerm_resource_group.formflow.location
  resource_group_name = azurerm_resource_group.formflow.name
}

resource "azurerm_subnet" "formflow" {
  name                 = "snet-formflow"
  resource_group_name  = azurerm_resource_group.formflow.name
  virtual_network_name = azurerm_virtual_network.formflow.name
  address_prefixes     = ["10.10.1.0/24"]
}

resource "azurerm_public_ip" "formflow" {
  name                = "pip-formflow"
  location            = azurerm_resource_group.formflow.location
  resource_group_name = azurerm_resource_group.formflow.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_security_group" "formflow" {
  name                = "nsg-formflow"
  location            = azurerm_resource_group.formflow.location
  resource_group_name = azurerm_resource_group.formflow.name

  security_rule {
    name                       = "allow-ssh"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = var.admin_source_ip
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow-http-https"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["80", "443"]
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface" "formflow" {
  name                = "nic-formflow"
  location            = azurerm_resource_group.formflow.location
  resource_group_name = azurerm_resource_group.formflow.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.formflow.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.formflow.id
  }
}

resource "azurerm_network_interface_security_group_association" "formflow" {
  network_interface_id      = azurerm_network_interface.formflow.id
  network_security_group_id = azurerm_network_security_group.formflow.id
}

resource "azurerm_linux_virtual_machine" "formflow" {
  name                = "vm-formflow-${var.environment}"
  resource_group_name = azurerm_resource_group.formflow.name
  location            = azurerm_resource_group.formflow.location
  size                = var.vm_size
  admin_username      = var.admin_username
  network_interface_ids = [
    azurerm_network_interface.formflow.id,
  ]

  admin_ssh_key {
    username   = var.admin_username
    public_key = file(pathexpand(var.ssh_public_key_path))
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  # Installs Docker and the Compose plugin on first boot.
  # Containers are NOT started here; the GitHub Actions pipeline deploys them.
  custom_data = base64encode(<<-EOF
    #cloud-config
    package_update: true
    packages:
      - docker.io
      - docker-compose-v2
    runcmd:
      - systemctl enable --now docker
      - usermod -aG docker ${var.admin_username}
  EOF
  )
}

resource "github_actions_secret" "deploy_host" {
  repository  = "formflow"
  secret_name = "DEPLOY_HOST"
  value       = azurerm_public_ip.formflow.ip_address
}
