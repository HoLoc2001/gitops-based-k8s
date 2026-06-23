variable "vault_namespace" {
  default = "vault"
}

variable "cluster_name" {
  description = "EKS Cluster Name"
  type        = string
}

variable "aws_region" {
  description = "AWS Region"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}
