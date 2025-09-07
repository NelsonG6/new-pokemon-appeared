resource "azurerm_resource_group" "rg" {
  name     = "new-pokemon-appeared"
  location = "WestUS3"
}

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

resource "azurerm_storage_account" "sa" {
  name                     = "${replace(azurerm_resource_group.rg.name, "-", "")}sa"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
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
