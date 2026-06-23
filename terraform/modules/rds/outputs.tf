output "aurora_endpoint" {
  value = aws_rds_cluster.aurora.endpoint
}

output "aurora_secret_path" {
  value = "secret/data/dev/aurora"
}
