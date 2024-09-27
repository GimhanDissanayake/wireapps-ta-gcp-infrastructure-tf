# Create SSH TLS keys
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "google_service_account" "default" {
  account_id   = "${local.default_name}-bastion"
  display_name = "bastion service account"
}

module "instance_template" {
  source  = "terraform-google-modules/vm/google//modules/instance_template"
  version = "~> 11.0"

  name_prefix        = "${local.default_name}-bastion"
  region             = var.region
  project_id         = var.project_id
  subnetwork         = "bastion-subnet-${var.region}"
  subnetwork_project = var.project_id

  service_account = {
    email  = google_service_account.default.email
    scopes = ["cloud-platform"]
  }
  tags = ["bastion"]

  source_image         = "ubuntu-2204-jammy-v20240519"
  source_image_family  = "ubuntu-2204-lts"
  source_image_project = "ubuntu-os-cloud"

  metadata = {
    ssh-keys = "${tls_private_key.ssh_key.public_key_openssh}"
  }

  depends_on = [
    module.gcp-network,
    google_project_service.gcp_services,
    google_project_organization_policy.bastion
  ]
}

module "compute_instance" {
  source  = "terraform-google-modules/vm/google//modules/compute_instance"
  version = "~> 11.0"

  region              = var.region
  hostname            = "${local.default_name}-bastion"
  zone                = var.regional_zones[0]
  subnetwork          = "bastion-subnet-${var.region}"
  num_instances       = 1
  instance_template   = module.instance_template.self_link
  deletion_protection = false

  access_config = [{
    nat_ip       = google_compute_address.bastion_ip.address
    network_tier = "STANDARD"
  }]

  depends_on = [
    module.instance_template, google_compute_address.bastion_ip, google_project_organization_policy.bastion
  ]
}

resource "google_project_iam_member" "bastion_gke" {
  project = var.project_id
  role    = "roles/container.developer"
  member  = "serviceAccount:${google_service_account.default.email}"
}

# OrgPolicyAllowExternalIPAssignment
resource "google_project_organization_policy" "bastion" {
  project    = var.project_id
  constraint = "constraints/compute.vmExternalIpAccess"

  list_policy {
    allow {
      values = ["projects/${var.project_id}/zones/${var.regional_zones[0]}/instances/${local.default_name}-bastion-001"]
    }
  }
}

resource "google_compute_address" "bastion_ip" {
  name         = "bastion-static-ip"
  region       = var.region
  network_tier = "STANDARD"

  depends_on = [
    google_project_service.gcp_services, google_project_organization_policy.bastion
  ]
}