variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-southeast-2"
}

variable "availability_zone" {
  description = "Availability zone to deploy the instance into (e.g. ap-southeast-2a)"
  type        = string
  default     = null
}

variable "project_name" {
  description = "Project name used for resource tagging"
  type        = string
  default     = "intai-me"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
}

variable "target_os" {
  description = "Target OS for EC2 instance: linux or windows"
  type        = string
  default     = "linux"

  validation {
    condition     = contains(["linux", "windows"], var.target_os)
    error_message = "target_os must be 'linux' or 'windows'."
  }
}

variable "domain_name" {
  description = "Domain name for the web server"
  type        = string
}

variable "certbot_email" {
  description = "Email address for Let's Encrypt certificate notifications"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "init_https" {
  description = "Set to true to init HTTPS certificate via SSM after DNS is configured"
  type        = bool
  default     = false
}