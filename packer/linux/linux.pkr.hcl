packer {
  required_plugins {
    amazon = {
      version = ">= 1.8.0"
      source  = "github.com/hashicorp/amazon"
    }
    ansible = {
      version = ">= 1.1.4"
      source  = "github.com/hashicorp/ansible"
    }
  }
}

locals {
  ami_arch = can(regex("[0-9]g", var.instance_type)) ? "arm64" : "x86_64"
}

source "amazon-ebs" "linux" {
  ami_name      = "${var.ami_name_prefix}-${formatdate("YYYYMMDD-hhmmss", timestamp())}"
  instance_type = var.instance_type
  region        = var.aws_region

  source_ami_filter {
    filters = {
      name                = "al2023-ami-2023.*-${local.ami_arch}"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["amazon"]
  }

  ssh_username = "ec2-user"

  tags = {
    Name    = var.ami_name_prefix
    Project = var.project_name
    OS      = "linux"
  }
}

build {
  sources = ["source.amazon-ebs.linux"]

  provisioner "ansible" {
    playbook_file = "../ansible/playbook-linux.yml"
    extra_arguments = [
      "--extra-vars",
      "domain_name=${var.domain_name} certbot_email=${var.certbot_email}",
    ]
  }
}
