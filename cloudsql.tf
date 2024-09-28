locals {
  read_replica_ip_configuration = {
    ipv4_enabled       = false
    require_ssl        = false
    ssl_mode           = "ENCRYPTED_ONLY"
    private_network    = null
    allocated_ip_range = null
  }
}

module "pg" {
  source  = "terraform-google-modules/sql-db/google//modules/postgresql"
  version = "~> 20.0"

  name                 = "${local.default_name}-psql-ha"
  random_instance_name = true
  project_id           = var.project_id
  database_version     = "POSTGRES_15"
  region               = var.region

  // Master configurations
  tier                            = var.pg_tier
  zone                            = var.regional_zones[0]
  availability_type               = var.pg_availability_type
  maintenance_window_day          = 7
  maintenance_window_hour         = 12
  maintenance_window_update_track = "stable"

  deletion_protection = false

  user_labels = {
    source = "terraform"
  }

  ip_configuration = {
    ipv4_enabled                                  = false
    require_ssl                                   = false
    private_network                               = module.gcp-network.network_id
    enable_private_path_for_google_cloud_services = true
    allocated_ip_range                            = null
    authorized_networks                           = null
  }

  backup_configuration = {
    enabled                        = true
    start_time                     = "00:55"
    location                       = null
    point_in_time_recovery_enabled = false
    transaction_log_retention_days = null
    retained_backups               = var.pg_retained_backups
    retention_unit                 = "COUNT"
  }

  db_name      = "default"
  db_charset   = "UTF8"
  db_collation = "en_US.UTF8"

  additional_databases = [
    for db_name in var.postgres_db_list : {
      name      = db_name
      charset   = "UTF8"
      collation = "en_US.UTF8"
    }
  ]

  user_name     = var.pg_admin_username
  user_password = var.pg_admin_password

  depends_on = [module.private-service-access]
}

module "private-service-access" {
  source  = "terraform-google-modules/sql-db/google//modules/private_service_access"
  version = "~> 20.0"

  project_id  = var.project_id
  vpc_network = module.gcp-network.network_name

  depends_on = [
    google_project_service.gcp_services,
    module.gcp-network
  ]
}