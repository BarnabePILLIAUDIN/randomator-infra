# Outputs from modules
output "kubectl_config_command" {
  description = "Command to configure kubectl"
  value       = "az aks get-credentials --resource-group ${module.resource_group.name} --name ${module.aks.cluster_name} --admin"
}