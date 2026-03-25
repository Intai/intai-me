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

source "amazon-ebs" "windows" {
  ami_name      = "${var.ami_name_prefix}-${formatdate("YYYYMMDD-hhmmss", timestamp())}"
  instance_type = var.instance_type
  region        = var.aws_region

  source_ami_filter {
    filters = {
      name                = "Windows_Server-2022-English-Full-Base-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["amazon"]
  }

  communicator   = "winrm"
  winrm_username = "Administrator"
  winrm_password = var.winrm_password
  winrm_use_ssl  = true
  winrm_insecure = true
  winrm_timeout  = "10m"

  user_data = templatefile("./scripts/configure-winrm.ps1", {
    admin_password = var.winrm_password
  })

  tags = {
    Name    = var.ami_name_prefix
    Project = var.project_name
    OS      = "windows"
  }
}

build {
  sources = ["source.amazon-ebs.windows"]

  provisioner "ansible" {
    playbook_file = "../ansible/playbook-windows.yml"
    use_proxy     = false
    ansible_env_vars = [
      "OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES",
    ]
    extra_arguments = [
      "--extra-vars",
      "ansible_user=Administrator domain_name=${var.domain_name} certbot_email=${var.certbot_email} ansible_winrm_server_cert_validation=ignore",
    ]
  }

}
