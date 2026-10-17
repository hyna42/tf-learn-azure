# Identifiants d'authentification Azure (Service Principal)
variable "ARM_SUBSCRIPTION_ID" {
  type        = string
  description = "Identifiant de l'abonnement sur lequel Terraform déploiera les ressources"
  nullable    = false
}

variable "ARM_CLIENT_ID" {
  type        = string
  description = "ID d'application (client), identifiant unique du Service Principal"
  nullable    = false
}

variable "ARM_CLIENT_SECRET" {
  type        = string
  description = "Mot de passe que Terraform utilisera pour s'authentifier"
  nullable    = false
  sensitive   = true
}

variable "ARM_TENANT_ID" {
  type        = string
  description = "Identifiant de l'annuaire Entra ID dans lequel est enregistré le Service Principal"
  nullable    = false
}

# Groupe de ressources et emplacement
variable "resource_group_name" {
  description = "Nom du groupe de ressources Azure"
  type        = string
}

variable "location" {
  description = "Région Azure dans laquelle déployer les ressources"
  type        = string
}

# Paramètres réseau
variable "vnet_address_space" {
  description = "Plage d'adresses IP pour le vNet"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "subnet_prefix" {
  description = "Préfixe IP pour le sous-réseau principal"
  type        = list(string)
  default     = ["10.0.1.0/24"]
}

variable "allowed_ssh_cidr" {
  description = "Adresse IP autorisé en connexion SSH"
  type        = string
}
# Machine virtuelle
variable "vm_name" {
  description = "Nom de la machine virtuelle"
  type        = string
}

variable "vm_size" {
  description = "Taille de la machine virtuelle"
  type        = string
  default     = "Standard_B1s"
}

variable "os_disk_size_gb" {
  description = "Taille du disque système en Go"
  type        = number
  default     = 30
}

# Image Ubuntu 24.04 LTS (x64 Gen2) — vérifiée à denmarkeast via az vm image show
variable "image_publisher" {
  description = "Éditeur de l'image"
  type        = string
  default     = "Canonical"
}

variable "image_offer" {
  description = "Offre de l'image"
  type        = string
  default     = "ubuntu-24_04-lts"
}

variable "image_sku" {
  description = "Référence (SKU) de l'image"
  type        = string
  default     = "server"
}

variable "image_version" {
  description = "Version de l'image (latest = la plus récente)"
  type        = string
  default     = "latest"
}

# Accès SSH
variable "admin_username" {
  description = "Nom d'utilisateur pour se connecter à la VM"
  type        = string
  default     = "adminuser"
}

# Tag environnement
variable "environment_tag" {
  description = "Indique l'environnement de déploiement (dev, test, prod)"
  type        = string
  default     = "dev"
}

variable "ssh_public_key" {
  description = "Clé publique SSH déposée dans la VM"
  type        = string
}
