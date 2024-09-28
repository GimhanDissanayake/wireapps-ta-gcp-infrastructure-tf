output "node_pool_service_account" {
  value = module.gke.service_account
}

output "gke_workload_service_account" {
  value = google_service_account.gke_workload_sa.email
}

output "dns_ns_records" {
  value = module.dns-public-zone.name_servers
}

output "bastion_external_ip" {
  value = module.bastion_pubip.addresses[0]
}

output "app_external_ip" {
  value = module.appvm_pubip[0].addresses[0]
}

# DB
output "postgres_db_instance_ip" {
  value = module.pg.instance_ip_address
}

output "postgres_db_private_ip" {
  value = module.pg.private_ip_address
}