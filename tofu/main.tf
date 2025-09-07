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

resource "azurerm_cosmosdb_account" "db" {
  name                       = "${azurerm_resource_group.rg.name}-cdba"
  resource_group_name        = azurerm_resource_group.rg.name
  location                   = azurerm_resource_group.rg.location
  offer_type                 = "Standard"
  kind                       = "MongoDB"
  automatic_failover_enabled = false
  free_tier_enabled          = true
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
    failover_priority = 1
  }
}

resource "azurerm_cosmosdb_mongo_database" "mongo_db" {
  name                = "${azurerm_resource_group.rg.name}-db"
  resource_group_name = azurerm_resource_group.rg.name
  account_name        = azurerm_cosmosdb_account.db.name
  throughput          = 400
}
