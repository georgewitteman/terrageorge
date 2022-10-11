data "aws_ami" "this" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5.10-hvm-2.0.20220912.1-x86_64-gp2"]
  }
}

resource "aws_launch_template" "this" {
  name                   = "${var.resource_name_prefix}-tailscale-relay"
  image_id               = data.aws_ami.this.id
  instance_type          = var.instance_type
  key_name               = var.ssh_key_name != null ? var.ssh_key_name : null
  vpc_security_group_ids = [aws_security_group.this.id]

  update_default_version = true

  iam_instance_profile {
    arn = aws_iam_instance_profile.tailscale.arn
  }

  user_data = base64encode(
    templatefile(
      "${path.module}/templates/install_tailscale.sh.tpl",
      {
        cidr                = data.aws_vpc.selected.cidr_block
        secrets_manager_arn = aws_secretsmanager_secret.authkey.arn
        region              = data.aws_region.current.name
      }
    )
  )

  network_interfaces {
    associate_public_ip_address = true
  }

  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      volume_size           = 20
      delete_on_termination = true
    }
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }
}

resource "aws_autoscaling_group" "this" {
  name                = "${var.resource_name_prefix}-tailscale-relay"
  min_size            = 1
  max_size            = 1
  desired_capacity    = 1
  vpc_zone_identifier = var.public_subnet_ids

  launch_template {
    id      = aws_launch_template.this.id
    version = aws_launch_template.this.latest_version
  }

  instance_refresh {
    strategy = "Rolling"
  }

  tag {
    key                 = "Name"
    value               = "${var.resource_name_prefix}-tailscale-relay"
    propagate_at_launch = true
  }

  tag {
    key                 = "${var.resource_name_prefix}-tailscale"
    value               = "server"
    propagate_at_launch = true
  }
}
