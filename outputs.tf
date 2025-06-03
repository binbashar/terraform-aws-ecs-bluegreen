output "cluster_name" {
  value = module.ecs_cluster.cluster_name
}

output "services" {
  value = module.ecs_cluster.services
}

output "turn_off_on_services_schedule" {
  value = var.turn_off_on_services_schedule
}


