# Main Configuration - Using Modules
# This file orchestrates all the modules to create the complete infrastructure

# Common tags for all resources
locals {
  common_tags = {
    environment = var.environment
    project     = var.project_name
    managed_by  = "terraform"
  }
}

# Resource Group Module
module "resource_group" {
  source = "./modules/resource-group"

  name     = var.resource_group_name
  location = var.location
  tags     = local.common_tags
}

module "network" {
  source = "./modules/network"

  resource_group_name           = module.resource_group.name
  location                     = module.resource_group.location
  vnet_name                    = var.vnet_name
  vnet_address_space           = var.vnet_address_space
  subnet_name                  = var.subnet_name
  subnet_address_prefixes      = var.subnet_address_prefixes
  aks_subnet_address_prefixes  = var.aks_subnet_address_prefixes
  tags                         = local.common_tags
}

# AKS Module
module "aks" {
  source = "./modules/aks"

  resource_group_name      = module.resource_group.name
  location                 = module.resource_group.location
  cluster_name             = var.aks_cluster_name
  kubernetes_version       = var.kubernetes_version
  node_count               = var.aks_node_count
  vm_size                  = var.aks_vm_size
  subnet_id                = module.network.aks_subnet_id
  vnet_subnet_id           = module.network.aks_subnet_id
  enable_private_cluster   = var.enable_private_cluster
  enable_auto_scaling      = var.enable_auto_scaling
  min_count                = var.aks_min_count
  max_count                = var.aks_max_count
  service_cidr             = var.service_cidr
  dns_service_ip           = var.dns_service_ip
  tags                     = local.common_tags
}