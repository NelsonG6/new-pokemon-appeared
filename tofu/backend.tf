terraform {
  backend "azurerm" {
    use_oidc             = true                                    # Can also be set via `ARM_USE_OIDC` environment variable.
    use_azuread_auth     = true                                    # Can also be set via `ARM_USE_AZUREAD` environment variable.
    tenant_id            = "4cda7170-067b-4002-af45-933da3207563"  # Can also be set via `ARM_TENANT_ID` environment variable.
    client_id            = "fe9dcc0e-101c-4291-af95-2ccadd9e5346"  # Can also be set via `ARM_CLIENT_ID` environment variable.
    storage_account_name = "nelsong6opentofu"
    container_name       = "new-pokemon-appears"
    key                  = "prod.tfstate"
  }
}
