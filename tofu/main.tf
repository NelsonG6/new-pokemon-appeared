resource "azurerm_resource_group" "rg" {
  name     = "new-pokemon-appeared"
  location = "WestUS3"
}

locals {
  home_ip = "71.236.251.57"
}

resource "azurerm_static_web_app" "site" {
  name                = "${azurerm_resource_group.rg.name}-site"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
}
