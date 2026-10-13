provider "azurerm" {
  # Configuration options
  features {}

  # Register Network provider
  resource_providers_to_register = [
    "Microsoft.Network",
    "Microsoft.Compute",
  ]

  subscription_id = var.ARM_SUBSCRIPTION_ID
  client_id       = var.ARM_CLIENT_ID
  client_secret   = var.ARM_CLIENT_SECRET
  tenant_id       = var.ARM_TENANT_ID

}