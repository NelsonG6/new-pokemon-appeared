resource "azurerm_resource_group" "rg" {
  name     = "new-pokemon-appears"
  location = "WestUS3"
}

# resource "azurerm_service_plan" "sp" {
#   name                = "${azurerm_resource_group.rg.name}-asp"
#   resource_group_name = azurerm_resource_group.rg.name
#   location            = azurerm_resource_group.rg.location
#   os_type             = "Linux"
#   sku_name            = "P1v2"
# }

# resource "azurerm_linux_web_app" "example" {
#   name                = "${azurerm_resource_group.rg.name}-wa"
#   resource_group_name = azurerm_resource_group.rg.name
#   location            = azurerm_service_plan.rg.location
#   service_plan_id     = azurerm_service_plan.sp.id
#   application_stack = {
#     node_version 
#   }
#   site_config {}
# }
