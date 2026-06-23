resource "random_password" "aurora" {
  length  = 20
  special = false
}

resource "aws_db_subnet_group" "aurora" {
  name       = "${var.project_name}-aurora-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "${var.project_name}-aurora-subnet-group"
  }
}

resource "aws_rds_cluster" "aurora" {
  cluster_identifier = "${var.project_name}-aurora"
  engine             = "aurora-postgresql"
  engine_version     = "16.4"
  database_name      = var.db_name
  master_username    = var.db_username
  master_password    = random_password.aurora.result

  db_subnet_group_name   = aws_db_subnet_group.aurora.name
  vpc_security_group_ids = [aws_security_group.aurora.id]

  backup_retention_period = 7
  skip_final_snapshot     = true
  deletion_protection     = false

  tags = {
    Name = "${var.project_name}-aurora"
  }
}

resource "aws_rds_cluster_instance" "aurora" {
  count              = 1
  identifier         = "${var.project_name}-aurora-${count.index + 1}"
  cluster_identifier = aws_rds_cluster.aurora.id

  instance_class = "db.t4g.medium"
  engine         = aws_rds_cluster.aurora.engine
}
