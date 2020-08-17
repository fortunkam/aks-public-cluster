output "aks_private_key_pem" {
  value = tls_private_key.aks.private_key_pem
}

output "aks_win_node_password" {
    value = random_password.aks_win_node_password.result
}

output "sql_password" {
    value = random_password.sql_password.result
}

