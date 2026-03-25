locals {
  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}

data "aws_ami" "app" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "tag:Project"
    values = [var.project_name]
  }

  filter {
    name   = "tag:OS"
    values = [var.target_os]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

resource "aws_instance" "app" {
  ami                    = data.aws_ami.app.id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]
  iam_instance_profile   = var.iam_instance_profile

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
    encrypted   = true
  }

  metadata_options {
    http_tokens                 = "required"
    http_endpoint               = "enabled"
    http_put_response_hop_limit = 1
  }

  user_data = var.target_os == "windows" ? (
    <<-POWERSHELL
    <powershell>
    [System.Environment]::SetEnvironmentVariable("DOMAIN_NAME", "${var.domain_name}", "Machine")
    [System.Environment]::SetEnvironmentVariable("CERTBOT_EMAIL", "${var.certbot_email}", "Machine")
    </powershell>
    POWERSHELL
    ) : (
    <<-BASH
    #!/bin/bash
    echo "DOMAIN_NAME=${var.domain_name}" >> /etc/environment
    echo "CERTBOT_EMAIL=${var.certbot_email}" >> /etc/environment
    systemctl start certbot-init.service
    BASH
  )

  tags = merge(local.tags, {
    Name = "${var.project_name}-${var.target_os}"
    OS   = var.target_os
  })
}

resource "null_resource" "init_https" {
  count = var.init_https ? 1 : 0

  triggers = {
    instance_id = aws_instance.app.id
  }

  provisioner "local-exec" {
    command = var.target_os == "windows" ? (
      "aws ssm send-command --instance-ids ${aws_instance.app.id} --document-name AWS-RunPowerShellScript --parameters '{\"commands\":[\"powershell.exe -ExecutionPolicy Bypass -File C:\\\\tools\\\\win-acme\\\\winacme-init.ps1\"]}' --region ${var.aws_region}"
      ) : (
      "aws ssm send-command --instance-ids ${aws_instance.app.id} --document-name AWS-RunShellScript --parameters '{\"commands\":[\"systemctl start certbot-init.service\"]}' --region ${var.aws_region}"
    )
  }
}

resource "aws_eip" "app" {
  instance = aws_instance.app.id
  domain   = "vpc"

  tags = merge(local.tags, {
    Name = "${var.project_name}-${var.target_os}-eip"
  })
}
