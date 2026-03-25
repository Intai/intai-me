module "vpc" {
  source            = "./modules/vpc"
  availability_zone = var.availability_zone
  project_name      = var.project_name
  environment       = var.environment
}

module "security" {
  source       = "./modules/security"
  project_name = var.project_name
  environment  = var.environment
  vpc_id       = module.vpc.vpc_id
}

module "compute" {
  source               = "./modules/compute"
  project_name         = var.project_name
  environment          = var.environment
  target_os            = var.target_os
  instance_type        = var.instance_type
  subnet_id            = module.vpc.public_subnet_id
  security_group_id    = module.security.instance_sg_id
  iam_instance_profile = module.security.instance_profile_name
  domain_name          = var.domain_name
  certbot_email        = var.certbot_email
}

module "dns" {
  source       = "./modules/dns"
  project_name = var.project_name
  environment  = var.environment
  domain_name  = var.domain_name
  elastic_ip   = module.compute.elastic_ip
}
