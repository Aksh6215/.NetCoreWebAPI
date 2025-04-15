provider "azurerm" {
    subscription_id = "7c08c6b0-62da-4c5d-9b2f-aa98aeb10f2e"
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "codecraft-rg"
  location = "East US"
}

resource "azurerm_container_registry" "acr" {
  name                = "codecraftacr"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Basic"
  admin_enabled       = true
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "codecraft-aks"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "codecraftaks"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_B2s"
  }

  identity {
    type = "SystemAssigned"
  }

  role_based_access_control_enabled = true

  network_profile {
    network_plugin = "azure"
  }

  depends_on = [azurerm_container_registry.acr]
}

resource "azurerm_role_assignment" "acr_pull" {
  principal_id         = azurerm_kubernetes_cluster.aks.identity[0].principal_id
  role_definition_name = "AcrPull"
  scope                = azurerm_container_registry.acr.id
}
