resource "azurerm_cosmosdb_account" "db" {
  name                       = "${azurerm_resource_group.rg.name}-cdba"
  resource_group_name        = azurerm_resource_group.rg.name
  location                   = azurerm_resource_group.rg.location
  offer_type                 = "Standard"
  kind                       = "MongoDB"
  automatic_failover_enabled = false
  free_tier_enabled          = true
  ip_range_filter            = [local.home_ip]
  capabilities {
    name = "EnableAggregationPipeline"
  }
  capabilities {
    name = "mongoEnableDocLevelTTL"
  }
  capabilities {
    name = "MongoDBv3.4"
  }
  capabilities {
    name = "EnableMongo"
  }
  consistency_policy {
    consistency_level       = "BoundedStaleness"
    max_interval_in_seconds = 300
    max_staleness_prefix    = 100000
  }
  geo_location {
    location          = "eastus"
    failover_priority = 0
  }
}

resource "azurerm_cosmosdb_mongo_database" "mongo_db" {
  name                = "${azurerm_resource_group.rg.name}-db"
  resource_group_name = azurerm_resource_group.rg.name
  account_name        = azurerm_cosmosdb_account.db.name
  throughput          = 400
}

import {
  to = azurerm_private_dns_zone.mongo
  id = "/subscriptions/6507cd03-8896-4ac1-b320-b291724179c4/resourceGroups/new-pokemon-appeared/providers/Microsoft.Network/privateDnsZones/privatelink.mongo.cosmos.azure.com"
}

resource "azurerm_private_dns_zone" "mongo" {
  name                = "privatelink.mongo.cosmos.azure.com"
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "mongo" {
  name                  = "mongo"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.mongo.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
}

resource "azurerm_private_endpoint" "cosmos" {
  name                          = "${azurerm_cosmosdb_account.db.name}-pe"
  resource_group_name           = azurerm_resource_group.rg.name
  location                      = azurerm_resource_group.rg.location
  subnet_id                     = azurerm_subnet.endpoints.id
  custom_network_interface_name = "${azurerm_cosmosdb_account.db.name}-pe-nic"
  private_service_connection {
    name                           = "mongo"
    private_connection_resource_id = azurerm_cosmosdb_account.db.id
    subresource_names              = ["MongoDB"]
    is_manual_connection           = false
  }
  private_dns_zone_group {
    name                 = "group"
    private_dns_zone_ids = [azurerm_private_dns_zone.mongo.id]
  }
}

