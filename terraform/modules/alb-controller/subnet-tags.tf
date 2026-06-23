resource "aws_ec2_tag" "public_subnet_elb" {
  count = length(var.public_subnet_ids)

  resource_id = var.public_subnet_ids[count.index]
  key         = "kubernetes.io/role/elb"
  value       = "1"
}

resource "aws_ec2_tag" "public_subnet_cluster" {
  count = length(var.public_subnet_ids)

  resource_id = var.public_subnet_ids[count.index]
  key         = "kubernetes.io/cluster/${var.cluster_name}"
  value       = "shared"
}
