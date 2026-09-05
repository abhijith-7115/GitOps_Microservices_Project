variable "aws_region" {
  description = "AWS region where resources will be provisioned"
  default     = "ap-south-1"
}


variable "instance_type_bastion_host" {
  description = "Instance type for the bastion_host instance"
  default     = "t3.micro"
}


variable "my_environment" {
  description = "Instance type for the EC2 instance"
  default     = "Dev"
}

variable "key_pair" {
  description = "key_pair for the EC2 instance"
}

variable "eks_admin_user_arn" {
  description = "The IAM User ARN that will be granted Cluster Admin permissions"
}
