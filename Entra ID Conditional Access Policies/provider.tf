terraform {
  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.47" # Pins to a recent, stable version
    }
  }
}
