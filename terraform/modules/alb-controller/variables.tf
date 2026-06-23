variable "cluster_name" {
  description = "EKS Cluster Name"
  type        = string
}

variable "aws_region" {
  description = "AWS Region"
  type        = string
}


variable "project_name" {
  description = "Project name for naming resources"
  type        = string
}

variable "oidc_issuer_url" {
  description = "OIDC issuer URL"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs"
  type        = list(string)
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}
