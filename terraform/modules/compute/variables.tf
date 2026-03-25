variable "aws_region" {
  type = string
}

variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "target_os" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "security_group_id" {
  type = string
}

variable "iam_instance_profile" {
  type = string
}

variable "domain_name" {
  type = string
}

variable "certbot_email" {
  type = string
}

variable "init_https" {
  type    = bool
  default = false
}
