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

  communicator = "ssh"
  ssh_username = "Administrator"
  ssh_timeout  = "10m"

  user_data = <<-EOF
    <powershell>
    # Install OpenSSH Server
    Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0

    # Fetch Packer's temporary public key from instance metadata
    $token = Invoke-RestMethod -Method PUT -Uri "http://169.254.169.254/latest/api/token" -Headers @{"X-aws-ec2-metadata-token-ttl-seconds" = "300"}
    $publicKey = Invoke-RestMethod -Uri "http://169.254.169.254/latest/meta-data/public-keys/0/openssh-key" -Headers @{"X-aws-ec2-metadata-token" = $token}

    # Add public key to administrators_authorized_keys
    $authKeysFile = "$env:ProgramData\ssh\administrators_authorized_keys"
    Set-Content -Path $authKeysFile -Value $publicKey
    icacls $authKeysFile /inheritance:r /grant "Administrators:F" /grant "SYSTEM:F"

    # Start sshd
    Set-Service -Name sshd -StartupType Automatic
    Start-Service sshd
    </powershell>
    EOF

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
      "ansible_user=Administrator domain_name=${var.domain_name} certbot_email=${var.certbot_email}",
    ]
  }

}
