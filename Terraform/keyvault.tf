resource "azurerm_key_vault" "keyvault" {
  name                = local.key_vault_name
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name
  tenant_id           = data.azurerm_client_config.current.tenant_id

  sku_name = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "get",
    ]

    secret_permissions = [
      "get",
      "set",
      "list",
      "delete"
    ]

    storage_permissions = [
      "get",
    ]
  }

}

resource "azurerm_key_vault_secret" "akswinnodepassword" {
  name         = "WinNodePassword"
  value        = random_password.aks_win_node_password.result
  key_vault_id = azurerm_key_vault.keyvault.id
}

resource "azurerm_key_vault" "aks_keyvault" {
  name                = local.aks_key_vault_name
  location            = azurerm_resource_group.spoke.location
  resource_group_name = azurerm_resource_group.spoke.name
  tenant_id           = data.azurerm_client_config.current.tenant_id

  sku_name = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "get",
    ]

    secret_permissions = [
      "get",
      "set",
      "list",
      "delete"
    ]

    certificate_permissions = [
      "get",
    ]
  }

}

resource "azurerm_key_vault_access_policy" "aksManaged" {
  key_vault_id = azurerm_key_vault.aks_keyvault.id

  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = azurerm_kubernetes_cluster.aks.identity[0].principal_id

  key_permissions = [
    "get",
  ]

  secret_permissions = [
    "get",
  ]

  certificate_permissions = [
    "get",
  ]

  depends_on = [azurerm_key_vault.aks_keyvault, azurerm_kubernetes_cluster.aks]
}