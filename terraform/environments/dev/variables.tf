variable "aws_region" {
  description = "Region in which AWS Resources to be created"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment Variable used as a prefix develop/staging/production"
  type        = string
  default     = "develop"
}

variable "business_department" {
  description = "Business Department in the large organization this Infrastructure belongs"
  type        = string
  default     = "DevOps"
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "dev"
}

variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
  default     = "vpc-01"
}

variable "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "vpc_public_subnets" {
  description = "Public subnets of the VPC"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24"]
}

variable "vpc_private_subnets" {
  description = "Private subnets of the VPC"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "vpc_database_subnets" {
  description = "Database subnets of the VPC"
  type        = list(string)
  default     = ["10.0.151.0/24", "10.0.152.0/24"]
}

variable "vpc_create_database_subnet" {
  description = "Create database subnets"
  type        = bool
  default     = false
}
