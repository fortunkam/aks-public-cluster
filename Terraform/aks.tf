resource "tls_private_key" "aks" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = local.aks_name
  location            = azurerm_resource_group.spoke.location
  resource_group_name = azurerm_resource_group.spoke.name
  dns_prefix          = local.aks_name
  kubernetes_version  = "1.17.9"
  node_resource_group = local.aks_node_resource_group_name

  default_node_pool {
    name           = "default"
    node_count     = 2
    vm_size        = "Standard_D2_v2"
    vnet_subnet_id = azurerm_subnet.aks.id
  }

  identity {
    type = "SystemAssigned"
  }

  linux_profile {
    admin_username = "AzureAdmin"
    ssh_key {
      key_data = tls_private_key.aks.public_key_openssh
    }
  }
  role_based_access_control {
    enabled = true
    azure_active_directory {
      managed                = true
      admin_group_object_ids = [var.aad-aks-group-id]
    }
  }

  network_profile {
    network_plugin = "azure"
  }



  addon_profile {
    azure_policy {
      enabled = true
    }

    oms_agent {
      enabled = true
      log_analytics_workspace_id = azurerm_log_analytics_workspace.loganalytics.id
    }
  }

  windows_profile {
    admin_username = local.aks_windows_node_username
    admin_password = random_password.aks_win_node_password.result
  }
}

resource "azurerm_kubernetes_cluster_node_pool" "windows" {
  name                  = local.aks_windows_node_pool_name
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  vm_size               = "Standard_DS2_v2"
  node_count            = 1
  vnet_subnet_id        = azurerm_subnet.aks.id
  os_type               = "Windows"
}

resource "azurerm_role_assignment" "aksacrpull" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.aks.identity[0].principal_id
}

resource "azurerm_role_assignment" "aks_spoke_contributor" {
  scope                = azurerm_resource_group.spoke.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_kubernetes_cluster.aks.identity[0].principal_id
}

resource "azurerm_role_assignment" "aks_spoke_network_contributor" {
  scope                = azurerm_subnet.aks.id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_kubernetes_cluster.aks.identity[0].principal_id
}

data "azurerm_resource_group" "aks_node_rg" {
  name = azurerm_kubernetes_cluster.aks.node_resource_group
}

resource "azurerm_role_assignment" "aks_managed_identity_operator" {
  scope                = data.azurerm_resource_group.aks_node_rg.id
  role_definition_name = "Managed Identity Operator"
  principal_id         = azurerm_kubernetes_cluster.aks.identity[0].principal_id
}

resource "azurerm_role_assignment" "aks_virtual_machine_contributor" {
  scope                = data.azurerm_resource_group.aks_node_rg.id
  role_definition_name = "Virtual Machine Contributor"
  principal_id         = azurerm_kubernetes_cluster.aks.identity[0].principal_id
}
