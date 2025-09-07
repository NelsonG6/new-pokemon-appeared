resource "azurerm_resource_group" "rg" {
  name     = "new-pokemon-appeared"
  location = "WestUS3"
}

locals {
  home_ip = "71.236.251.57"
}
