output "node_pool_service_account" {
  value = module.gke.service_account
}

output "gke_workload_service_account" {
  value = google_service_account.gke_workload_sa.email
}

output "dns_ns_records" {
  value = module.dns-public-zone.name_servers
}