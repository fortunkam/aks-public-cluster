variable location {
  default = "uksouth"
}
variable prefix {
  default = "mfk8s"
}

variable devopsUrl {
}

variable devopsPatToken {
}

variable devopsBuildAgentPool {
}

variable devopsDeployAgentPool {
}

variable sqlUsername {
  default = "sqladmin"
}

variable aad-aks-group-id {
}


locals {
  rg_hub_name               = "${var.prefix}-hub-rg"
  rg_spoke_name             = "${var.prefix}-spoke-rg"
  vnet_hub_name             = "${var.prefix}-hub-vnet"
  vnet_spoke_name           = "${var.prefix}-spoke-vnet"
  vnet_hub_iprange          = "10.0.0.0/16"
  vnet_spoke_iprange        = "10.1.0.0/16"
  aks_subnet                = "aks"
  aks_subnet_iprange        = "10.1.1.0/24"
  appgateway_subnet         = "appgateway"
  appgateway_subnet_iprange = "10.1.2.0/24"
  hub_to_spoke_vnet_peer    = "${var.prefix}-hub-spoke-peer"
  spoke_to_hub_vnet_peer    = "${var.prefix}-spoke-hub-peer"

  key_vault_name               = "${var.prefix}kv"
  acr_name                     = "${var.prefix}acr"
  aks_name                     = "${var.prefix}-aks"
  aks_node_resource_group_name = "${var.prefix}-aks-node-rg"
  aks_windows_node_pool_name   = "win"

  appgateway                           = "${var.prefix}-agw"
  appgateway_publicip                  = "${var.prefix}-agw-ip"
  appgateway_gateway_ipconfig_name     = "${var.prefix}-agw-gateway-ipconfig"
  appgateway_frontend_http_port_name   = "${var.prefix}-agw-port-http"
  appgateway_frontend_ipconfig_name    = "${var.prefix}-agw-frontend-ipconfig"
  appgateway_listener_name             = "${var.prefix}-agw-http-listener"
  appgateway_backend_address_pool_name = "${var.prefix}-agw-backend-address-pool"
  appgateway_request_routing_rule_name = "${var.prefix}-agw-routing-rule"
  appgateway_http_setting_name         = "${var.prefix}-agw-http-setting"

  sql_private_endpoint = "${var.prefix}-sql-private-endpoint"
  sql_private_link     = "${var.prefix}-sql-private-link"

  sql_server_name  = "${var.prefix}-sql"
  mydrivingdb_name = "mydrivingDB"

  aks_key_vault_name = "${var.prefix}akskv"

  loganalytics_workspace_name = "${var.prefix}-log-analytics"

  aks_windows_node_username = "azureadmin"

}

data "azurerm_client_config" "current" {
}
data "azurerm_subscription" "primary" {
}

resource "random_password" "aks_win_node_password" {
  keepers = {
    resource_group = azurerm_resource_group.spoke.name
  }
  length           = 16
  special          = true
  override_special = "_%@"
}