# Identifiants d'authentification Azure
variable "ARM_SUBSCRIPTION_ID" {
  type        = string
  description = "identifiant de l’abonnement sur lequel Terraform déploiera les ressources"
  nullable    = false
}

variable "ARM_CLIENT_ID" {
  type        = string
  description = "ID d'application (client), identifiant unique de votre SP"
  nullable    = false
}

variable "ARM_CLIENT_SECRET" {
  type        = string
  description = "mot de passe que Terraform utilisera pour s’authentifier"
  nullable    = false
  sensitive = true
}


variable "ARM_TENANT_ID" {
  type        = string
  description = "identifiant de l’annuaire Entra ID dans lequel est enregistré le SP"
  nullable    = false
}
