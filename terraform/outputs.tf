output "bastion_public_ip" {
  description = "The public IP address of the Bastion Host"
  value       = aws_instance.bastion_host.public_ip
}

output "eks_worker_node_ips" {
  description = "The private IP addresses of the active EKS worker nodes"
  value       = data.aws_instances.eks_nodes.private_ips
}
