data "aws_ami" "ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  owners = ["amazon"]
}

resource "aws_launch_configuration" "launch_config" {
  associate_public_ip_address = false
  image_id                    = data.aws_ami.ami.id
  instance_type               = var.instance_type
  name_prefix                 = "${var.project}-${var.env}-ecs-ec2-"

  lifecycle {
    create_before_destroy = true
  }
}
