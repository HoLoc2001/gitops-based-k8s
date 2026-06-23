resource "vault_kv_secret_v2" "aurora" {
  mount = "secret"
  name  = "dev/aurora"

  data_json = jsonencode({
    DB_HOST     = aws_rds_cluster.aurora.endpoint
    DB_PORT     = "5432"
    DB_NAME     = var.db_name
    DB_USERNAME = var.db_username
    DB_PASSWORD = random_password.aurora.result
  })
}
