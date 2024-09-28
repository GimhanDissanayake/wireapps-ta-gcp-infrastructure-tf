module "gcp-network" {
  source  = "terraform-google-modules/network/google"
  version = ">= 9.0"

  project_id   = var.project_id
  network_name = "${local.default_name}-vpc"

  subnets = [
    for index, subnet in var.subnet_names : {
      subnet_name           = "${subnet}-${var.region}"
      subnet_ip             = var.subnet_cidr[index]
      subnet_region         = var.region
      subnet_private_access = "true"
    }
  ]

  secondary_ranges = {
    "gke-subnet-${var.region}" = [
      {
        range_name    = var.ip_range_pods_name
        ip_cidr_range = "10.220.0.0/18"
      },
      {
        range_name    = var.ip_range_services_name
        ip_cidr_range = "10.220.64.0/18"
      },
    ]
  }

  ingress_rules = [{
    name               = "${local.default_name}-allow-ssh-iap"
    direction          = "INGRESS"
    priority           = 1001
    destination_ranges = ["0.0.0.0/0"]
    source_ranges      = ["35.235.240.0/20"]
    target_tags        = ["allow-ssh-iap"]
    allow = [{
      protocol = "tcp"
      ports    = ["22"]
    }]
    }
  ]

  depends_on = [
    google_project_service.gcp_services
  ]
}

resource "google_compute_router" "router" {
  project = var.project_id
  name    = "${local.default_name}-nat-router"
  network = module.gcp-network.network_name
  region  = var.region
}

module "cloud-nat" {
  source  = "terraform-google-modules/cloud-nat/google"
  version = "~> 5.0"

  project_id                         = var.project_id
  region                             = var.region
  router                             = google_compute_router.router.name
  name                               = "${local.default_name}-nat"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  depends_on = [
    module.gcp-network
  ]
}