# Resource Group Module
# This module creates an Azure Resource Group

variable "name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region for the resource group"
  type        = string
}

variable "tags" {
  description = "Tags to apply to the resource group"
  type        = map(string)
  default     = {}
}

resource "azurerm_resource_group" "main" {
  name     = var.name
  location = var.location
  tags     = var.tags
}

output "id" {
  description = "ID of the resource group"
  value       = azurerm_resource_group.main.id
}

output "name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.main.name
}

output "location" {
  description = "Location of the resource group"
  value       = azurerm_resource_group.main.location
}
