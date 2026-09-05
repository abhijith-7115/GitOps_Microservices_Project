###########----FETCH LATEST UBUNTU AMI----################
data "aws_ami" "ubuntu" { ## This Terraform block is used to find the latest Ubuntu-AMI in AWS automatically
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

#############----Bastion Host Sg----##################
resource "aws_security_group" "bastion_sg" {
  name        = "bastion_host_SG"
  description = "Allow user to connect"
  vpc_id      = module.vpc.vpc_id

  tags = merge(local.tags, { Name = "${local.name}-bastion-sg" })
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_bastion" {
  security_group_id = aws_security_group.bastion_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4_bastion" {
  security_group_id = aws_security_group.bastion_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

#############----Bastion Host----##################
resource "aws_instance" "bastion_host" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type_bastion_host
  key_name               = var.key_pair
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]
  subnet_id              = module.vpc.public_subnets[0]
  user_data              = file("${path.module}/bastion_user_data.sh")

  tags = merge(local.tags, { Name = "${local.name}-Bastion-Host" })

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  lifecycle {
    ignore_changes = [
      ami,
    ]
  }
}
