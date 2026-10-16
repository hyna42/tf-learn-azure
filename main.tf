# **** 1. Création du Groupe de ressources ****

#  groupe de ressources principale
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
  tags     = local.common_tags
}


# **** 2. Configuration du réseau ****
# Réseau virtuel principal
resource "azurerm_virtual_network" "vnet" {
  name                = "${var.vm_name}-vnet"
  address_space       = var.vnet_address_space
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  tags                = local.common_tags
}

# Sous-réseau associé
resource "azurerm_subnet" "subnet" {
  name                 = "${var.vm_name}-subnet"
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.subnet_prefix
  resource_group_name  = azurerm_resource_group.rg.name
}

# Adresse IP publique pour accéder à la VM
resource "azurerm_public_ip" "public_ip" {
  name                = "${var.vm_name}-ip"
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  location            = azurerm_resource_group.rg.location
  sku                 = "Standard"
  tags                = local.common_tags
}

# **** 3. Sécurité Réseau (NetworkSecurityGroup) ****
resource "azurerm_network_security_group" "nsg" {
  name                = "${var.vm_name}-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  # Ouvrir le port SSH
  security_rule {
    name                   = "Allow_SSH"
    priority               = 1001
    direction              = "Inbound"
    access                 = "Allow"
    protocol               = "Tcp"
    source_port_range      = "*"
    destination_port_range = "22"

    source_address_prefix = var.allowed_ssh_cidr

    destination_address_prefix = "*"
  }

  tags = local.common_tags
}

# **** 4. Interface Réseau (NetworkInterface) ****
resource "azurerm_network_interface" "nic" {
  name                = "${var.vm_name}-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip.id
  }
}

# **** 5. Association du NSG avec la carte réseau ****
resource "azurerm_network_interface_security_group_association" "nsg_assoc" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# **** 6. Déploiement de la VM ubuntu ****
resource "azurerm_linux_virtual_machine" "vm" {
  name                = "${var.vm_name}-vm"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  size           = var.vm_size
  admin_username = var.admin_username

  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]

  os_disk {
    name = "${var.vm_name}-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb = var.os_disk_size_gb
  }
  source_image_reference {
    publisher = var.image_publisher
    offer     = var.image_offer
    sku       = var.image_sku
    version   = var.image_version
  }
  # authentification par une clé SSH publique
  admin_ssh_key {
    username   = var.admin_username
    public_key = file("${var.ssh_public_key}")
  }

  # authentification par mot de passe désactiv 
  disable_password_authentication = true

  tags = local.common_tags
}


