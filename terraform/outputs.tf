output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "instance_id" {
  description = "EC2 instance ID"
  value       = module.compute.instance_id
}

output "elastic_ip" {
  description = "Elastic IP address"
  value       = module.compute.elastic_ip
}

output "nameservers" {
  description = "Update your domain registrar with these nameservers"
  value       = module.dns.nameservers
}
