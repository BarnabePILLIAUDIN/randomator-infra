# AKS Module
# This module creates an Azure Kubernetes Service cluster in a private subnet

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region for resources"
  type        = string
}

variable "cluster_name" {
  description = "Name of the AKS cluster"
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.31.1"
}

variable "node_count" {
  description = "Number of nodes in the default node pool"
  type        = number
  default     = 2
}

variable "vm_size" {
  description = "Size of the virtual machines for nodes"
  type        = string
  default     = "Standard_B2s"
}

variable "subnet_id" {
  description = "ID of the subnet for the AKS cluster"
  type        = string
}

variable "vnet_subnet_id" {
  description = "ID of the subnet for the node pool"
  type        = string
}

variable "enable_private_cluster" {
  description = "Enable private cluster (no public API server endpoint)"
  type        = bool
  default     = false
}

variable "enable_auto_scaling" {
  description = "Enable auto scaling for the node pool"
  type        = bool
  default     = true
}

variable "min_count" {
  description = "Minimum number of nodes for auto scaling"
  type        = number
  default     = 1
}

variable "max_count" {
  description = "Maximum number of nodes for auto scaling"
  type        = number
  default     = 5
}

variable "enable_rbac" {
  description = "Enable RBAC on the AKS cluster"
  type        = bool
  default     = true
}

variable "network_plugin" {
  description = "Network plugin to use (azure or kubenet)"
  type        = string
  default     = "azure"
}

variable "service_cidr" {
  description = "CIDR for Kubernetes services"
  type        = string
  default     = "10.1.0.0/16"
}

variable "dns_service_ip" {
  description = "IP address for DNS service"
  type        = string
  default     = "10.1.0.10"
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

# AKS Cluster
resource "azurerm_kubernetes_cluster" "main" {
  name                = var.cluster_name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.cluster_name
  kubernetes_version  = var.kubernetes_version

  # Enable private cluster
  private_cluster_enabled = var.enable_private_cluster

  # Network configuration
  network_profile {
    network_plugin    = var.network_plugin
    service_cidr      = var.service_cidr
    dns_service_ip    = var.dns_service_ip
  }

  # Default node pool
  default_node_pool {
    name                = "default"
    vm_size             = var.vm_size
    node_count          = var.enable_auto_scaling ? null : var.node_count
    min_count           = var.enable_auto_scaling ? var.min_count : null
    max_count           = var.enable_auto_scaling ? var.max_count : null
    enable_auto_scaling = var.enable_auto_scaling
    vnet_subnet_id      = var.vnet_subnet_id
    
    # Enable auto-upgrade
    upgrade_settings {
      max_surge = "33%"
    }
  }

  # Identity configuration
  identity {
    type = "SystemAssigned"
  }

  # RBAC configuration
  role_based_access_control_enabled = var.enable_rbac

  tags = var.tags
}

output "cluster_id" {
  description = "ID of the AKS cluster"
  value       = azurerm_kubernetes_cluster.main.id
}

output "cluster_name" {
  description = "Name of the AKS cluster"
  value       = azurerm_kubernetes_cluster.main.name
}

output "cluster_fqdn" {
  description = "FQDN of the AKS cluster"
  value       = azurerm_kubernetes_cluster.main.fqdn
}

output "cluster_private_fqdn" {
  description = "Private FQDN of the AKS cluster"
  value       = azurerm_kubernetes_cluster.main.private_fqdn
}

output "cluster_portal_fqdn" {
  description = "Portal FQDN of the AKS cluster"
  value       = azurerm_kubernetes_cluster.main.portal_fqdn
}

output "kube_config" {
  description = "Kubernetes configuration"
  value       = azurerm_kubernetes_cluster.main.kube_config_raw
  sensitive   = true
}

output "kube_config_host" {
  description = "Kubernetes cluster host"
  value       = azurerm_kubernetes_cluster.main.kube_config.0.host
  sensitive   = true
}

output "kube_config_client_key" {
  description = "Kubernetes client key"
  value       = azurerm_kubernetes_cluster.main.kube_config.0.client_key
  sensitive   = true
}

output "kube_config_client_certificate" {
  description = "Kubernetes client certificate"
  value       = azurerm_kubernetes_cluster.main.kube_config.0.client_certificate
  sensitive   = true
}

output "kube_config_cluster_ca_certificate" {
  description = "Kubernetes cluster CA certificate"
  value       = azurerm_kubernetes_cluster.main.kube_config.0.cluster_ca_certificate
  sensitive   = true
}

output "node_resource_group" {
  description = "Resource group containing the AKS nodes"
  value       = azurerm_kubernetes_cluster.main.node_resource_group
}
