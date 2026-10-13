# **** 1. Création du Groupe de ressources ****

#  groupe de ressources principale
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}


# **** 2. Configuration du réseau ****
# Réseau virtuel principal
resource "azurerm_virtual_network" "vnet" {
  name                = "${var.vm_name}-vnet"
  address_space       = var.vnet_address_space
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
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
  # TODO ajouuter les tags
  tags = local.common_tags

}

# **** 3. Sécurité Réseau (NSG) ****
