variable "aws_region" {
  type    = string
  default = "ap-southeast-2"
}

variable "instance_type" {
  type    = string
  default = "t4g.nano"
}

variable "ami_name_prefix" {
  type    = string
  default = "intai-me-linux"
}

variable "domain_name" {
  type = string
}

variable "certbot_email" {
  type = string
}

variable "project_name" {
  type    = string
  default = "intai-me"
}
