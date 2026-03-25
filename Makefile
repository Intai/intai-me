include .env

TARGET_OS ?= linux
PACKER_DIR = packer/$(TARGET_OS)
TERRAFORM_DIR = terraform

PACKER_VARS = \
	-var "aws_region=$(AWS_REGION)" \
	-var "domain_name=$(DOMAIN_NAME)" \
	-var "certbot_email=$(CERTBOT_EMAIL)" \
	-var "instance_type=$(INSTANCE_TYPE)" \
	-var "project_name=$(PROJECT_NAME)"

ifeq ($(TARGET_OS),windows)
PACKER_VARS += -var "winrm_password=$$(openssl rand -base64 24)"
endif

TERRAFORM_VARS = \
	-var "aws_region=$(AWS_REGION)" \
	-var "domain_name=$(DOMAIN_NAME)" \
	-var "certbot_email=$(CERTBOT_EMAIL)" \
	-var "instance_type=$(INSTANCE_TYPE)" \
	-var "vpc_cidr=$(VPC_CIDR)" \
	-var "project_name=$(PROJECT_NAME)" \
	-var "environment=$(ENVIRONMENT)" \
	-var "target_os=$(TARGET_OS)" \
	$(if $(AVAILABILITY_ZONE),-var "availability_zone=$(AVAILABILITY_ZONE)")

.PHONY: help install ami init plan deploy destroy validate

.DEFAULT_GOAL := help

help: ## Show available commands
	@grep -hE '^[a-zA-Z_-]+:.*##' $(MAKEFILE_LIST) | awk -F ':.*## ' '{printf "  \033[36m%-12s\033[0m %s\n", $$1, $$2}'

install: ## Install Python dependencies
	pip install .

ami: ## Build AMI with Packer
	cd $(PACKER_DIR) && packer init . && packer build $(PACKER_VARS) .

init: ## Initialize Terraform
	cd $(TERRAFORM_DIR) && terraform init

plan: ## Preview Terraform changes
	cd $(TERRAFORM_DIR) && terraform plan $(TERRAFORM_VARS)

deploy: ## Apply Terraform changes
	cd $(TERRAFORM_DIR) && terraform apply $(TERRAFORM_VARS)

destroy: ## Tear down Terraform resources
	cd $(TERRAFORM_DIR) && terraform destroy $(TERRAFORM_VARS)

validate: ## Validate Packer and Terraform configs
	cd $(PACKER_DIR) && packer init . && packer validate $(PACKER_VARS) .
	cd $(TERRAFORM_DIR) && terraform init -backend=false && terraform validate
