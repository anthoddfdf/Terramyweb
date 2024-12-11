provider "aws" {
  region = "us-east-1"
}
# Create a VPC
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "my-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = true

  tags = {
    terraform = "true"
    Evirument = var.environment
  }
}
resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = module.vpc.vpc_id

  tags = {
    Name = "allow_tls"
  }
}

resource "aws_security_group" "allow" {
  name        = "allow"
  description = "Allow TLS inbound traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "TLS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.cidr_blo
  }
  ingress {
    description = "TLS from VPC"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = var.cidr_blo
  }
  ingress {
    description = "TLS from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.cidr_blo
  }
  ingress {
    description = "TLS from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.cidr_blo
  }
  ingress {
    description = "TLS from VPC"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = var.cidr_blo
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.cidr_blo
  }

  tags = {
    Name = "my_security_gp"
  }

}
//resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv6" {
//  security_group_id = aws_security_group.allow_tls.id
//  cidr_ipv6         = "::/0"
//  ip_protocol       = "-1" # semantically equivalent to all ports
//}
#This is the security key for the below instance
resource "tls_private_key" "mykey" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "local_file" "private_key_pem" {
  content  = tls_private_key.mykey.private_key_pem
  filename = "Mypro.pem"
}

# Save the public key to a local file
resource "local_file" "public_key_pem" {
  content  = tls_private_key.mykey.public_key_openssh
  filename = "publickey.ppk"
}
resource "aws_key_pair" "public_key_pem2" {
  key_name   = "publickey-2${var.environment}"
  public_key = tls_private_key.mykey.public_key_openssh

  lifecycle {
    ignore_changes = [key_name]
  }
}


resource "aws_instance" "njinx_server" {
  ami                         = var.ami
  instance_type               = var.size
  security_groups             = [aws_security_group.allow.id]
  subnet_id                   = module.vpc.public_subnets[0]
  associate_public_ip_address = var.publicipa
  key_name                    = aws_key_pair.public_key_pem2.key_name

  user_data = file("file.sh")
  tags = {
    Name = "wedapp"
  }
}
resource "aws_ami_from_instance" "aws_ami" {
  name               = "instanceami"
  source_instance_id = aws_instance.njinx_server.id
}
resource "aws_launch_template" "app" {
  name = "app-launch-template"

  image_id      = aws_ami_from_instance.aws_ami.id # Replace with your AMI ID
  instance_type = "t2.micro"

  network_interfaces {
    associate_public_ip_address = var.publicipa
    security_groups             = [aws_security_group.allow.id]
    subnet_id                   = module.vpc.public_subnets[0] # Pick one subnet
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "webapp"
    }
  }

  tags = {
    Name = "app-launch-template"
  }
}

resource "aws_autoscaling_group" "autowebapp" {
  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }

  vpc_zone_identifier = module.vpc.public_subnets

  min_size                  = 3
  max_size                  = 4
  desired_capacity          = 3
  health_check_type         = "ELB"
  health_check_grace_period = 300

  target_group_arns = [aws_lb_target_group.webapptg.arn]

  tag {
    key                 = "Name"
    value               = "webapp-asg-instance"
    propagate_at_launch = true
  }
}


resource "aws_lb" "mywedapp" {
  name               = "mywedapp"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.allow.id]
  subnets            = module.vpc.public_subnets

}

resource "aws_lb_target_group" "webapptg" {
  name     = "myappweb"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id
}
resource "aws_lb_listener" "app_listener" {
  load_balancer_arn = aws_lb.mywedapp.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.webapptg.arn
  }

}

#  target_group_health {
#    dns_failover {
#      minimum_healthy_targets_count      = "1"
#      minimum_healthy_targets_percentage = "off"
#    }

#    unhealthy_state_routing {
#      minimum_healthy_targets_count      = "1"
#      minimum_healthy_targets_percentage = "off"
#    }
#  }


