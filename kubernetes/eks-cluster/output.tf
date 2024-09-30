output "cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = module.eks_al2.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster."
  value       = module.eks_al2.cluster_security_group_id
}
