locals {
  common_tags = {
    environment = var.environment_tag
    project     = "tf-learn-azure"
    managed_by  = "terraform"
  }
}