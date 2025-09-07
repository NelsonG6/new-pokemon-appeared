module "subnet_addrs" {
  source = "hashicorp/subnets/cidr"

  base_cidr_block = "10.0.0.0/16"
  networks = [
    {
      name     = "endpoints"
      new_bits = 8
    },
    {
      name     = "asp"
      new_bits = 8
    },
  ]
}

resource "azurerm_virtual_network" "vnet" {
  name                = "${azurerm_resource_group.rg.name}-vnet"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  address_space       = [module.subnet_addrs.base_cidr_block]
}

resource "azurerm_subnet" "endpoints" {
  name                 = "${azurerm_virtual_network.vnet.name}-pesubnet"
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = azurerm_resource_group.rg.name
  address_prefixes     = module.subnet_addrs.network_cidr_blocks["endpoints"]
}

resource "azurerm_subnet" "asp" {
  name                 = "${azurerm_virtual_network.vnet.name}-aspsubnet"
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = azurerm_resource_group.rg.name
  address_prefixes     = module.subnet_addrs.network_cidr_blocks["asp"]
}
