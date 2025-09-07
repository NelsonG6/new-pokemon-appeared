resource "azurerm_service_plan" "sp" {
  name                = "${azurerm_resource_group.rg.name}-asp"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  os_type             = "Linux"
  sku_name            = "B1"
}

resource "azurerm_linux_web_app" "lwa" {
  name                = "${azurerm_resource_group.rg.name}-wa"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_service_plan.sp.location
  service_plan_id     = azurerm_service_plan.sp.id
  site_config {
    application_stack {
      node_version = "22-lts"
    }
  }
}

resource "azurerm_linux_function_app" "fa" {
  name                       = "${azurerm_resource_group.rg.name}-fa"
  resource_group_name        = azurerm_resource_group.rg.name
  location                   = azurerm_resource_group.rg.location
  storage_account_name       = azurerm_storage_account.sa.name
  storage_account_access_key = azurerm_storage_account.sa.primary_access_key
  service_plan_id            = azurerm_service_plan.sp.id
  site_config {}
}

resource "azurerm_private_dns_zone" "azurewebsites" {
  name                = "privatelink.azurewebsites.net"
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "azurewebsites" {
  name                  = "azurewebsites"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.azurewebsites.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
}

resource "azurerm_private_endpoint" "azurewebsites" {
  name                          = "${azurerm_linux_function_app.fa.name}-pe"
  resource_group_name           = azurerm_resource_group.rg.name
  location                      = "westus2"
  subnet_id                     = azurerm_subnet.endpoints.id
  custom_network_interface_name = "${azurerm_linux_function_app.fa.name}-pe-nic"
  private_service_connection {
    name                           = "azurewebsites"
    private_connection_resource_id = azurerm_linux_function_app.fa.id
    subresource_names              = ["sites"]
    is_manual_connection           = false
  }
  private_dns_zone_group {
    name                 = "group"
    private_dns_zone_ids = [azurerm_private_dns_zone.azurewebsites.id]
  }
}
