variable "aws_region" {
  default = "ap-southeast-1"
}

variable "project_name" {
  default = "gitops-platform"
}

variable "vpc_id" {}

variable "private_subnet_ids" {
  type = list(string)
}

variable "eks_node_security_group_id" {}

variable "db_name" {
  default = "appdb"
}

variable "db_username" {
  default = "appuser"
}

variable "vault_addr" {}

variable "vault_token" {
  sensitive = true
}
