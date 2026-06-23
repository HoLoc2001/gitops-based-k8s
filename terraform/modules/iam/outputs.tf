output "cluster_iam_role_name" {
  description = "IAM role name of the EKS cluster."
  value       = aws_iam_role.eks_master_role.name
}

output "cluster_iam_role_arn" {
  description = "IAM role ARN of the EKS cluster."
  value       = aws_iam_role.eks_master_role.arn
}

output "eks_nodegroup_role_arn" {
  description = "IAM role ARN of the EKS nodegroup."
  value       = aws_iam_role.eks_nodegroup_role.arn
}

output "eks_clusterpolicy_id" {
  description = "EKS Cluster Policy ID"
  value       = aws_iam_role_policy_attachment.eks-AmazonEKSClusterPolicy.id
}

output "eks_vpc_resource_controller_id" {
  description = "EKS VPC Resource Controller Policy ID"
  value       = aws_iam_role_policy_attachment.eks-AmazonEKSVPCResourceController.id
}
