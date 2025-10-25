# Variables for infrastructure configuration
variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "randomator-rg"
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "France Central"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "randomator"
}

# Network Configuration Variables
variable "vnet_name" {
  description = "Name of the virtual network"
  type        = string
  default     = "randomator-vnet"
}

variable "vnet_address_space" {
  description = "Address space for the virtual network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "subnet_name" {
  description = "Name of the subnet"
  type        = string
  default     = "randomator-subnet"
}

variable "subnet_address_prefixes" {
  description = "Address prefixes for the subnet"
  type        = list(string)
  default     = ["10.0.1.0/24"]
}

variable "aks_subnet_address_prefixes" {
  description = "Address prefixes for the AKS subnet"
  type        = list(string)
  default     = ["10.0.2.0/24"]
}

# AKS Configuration Variables
variable "aks_cluster_name" {
  description = "Name of the AKS cluster"
  type        = string
  default     = "randomator-cluster"
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.31.1"
}

variable "aks_node_count" {
  description = "Number of nodes in the default node pool"
  type        = number
  default     = 2
}

variable "aks_vm_size" {
  description = "Size of the virtual machines for AKS nodes"
  type        = string
  default     = "Standard_B2s"
}

variable "enable_private_cluster" {
  description = "Enable private cluster (no public API server endpoint)"
  type        = bool
  default     = false
}

variable "enable_auto_scaling" {
  description = "Enable auto scaling for the AKS node pool"
  type        = bool
  default     = true
}

variable "aks_min_count" {
  description = "Minimum number of nodes for auto scaling"
  type        = number
  default     = 1
}

variable "aks_max_count" {
  description = "Maximum number of nodes for auto scaling"
  type        = number
  default     = 5
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