resource "google_service_account" "default" {
  account_id   = "${local.default_name}-bastion"
  display_name = "bastion service account"
}

module "bastion_service_account" {

  source     = "terraform-google-modules/service-accounts/google"
  version    = "~> 4.0"
  project_id = var.project_id
  prefix     = local.default_name
  names      = ["bastion-sa"]
  project_roles = [
    "${var.project_id}=>roles/storage.objectCreator"
  ]
}

module "instance_template" {
  source  = "terraform-google-modules/vm/google//modules/instance_template"
  version = "~> 11.0"

  name_prefix          = "${local.default_name}-bastion"
  region               = var.region
  project_id           = var.project_id
  subnetwork           = "bastion-subnet-${var.region}"
  subnetwork_project   = var.project_id
  source_image         = "ubuntu-2204-jammy-v20240519"
  source_image_family  = "ubuntu-2204-lts"
  source_image_project = "ubuntu-os-cloud"

  metadata = {
    "ssh-keys" = <<EOT
      ${tls_private_key.bastion_ssh_keys.public_key_openssh}
     EOT
  }

  service_account = {
    email  = module.bastion_service_account.email
    scopes = ["cloud-platform"]
  }

  tags = ["allow-ssh-iap", "bastion"]

  startup_script = data.template_file.bastion_install_template.rendered

  depends_on = [
    module.gcp-network,
    google_project_service.gcp_services,
    google_project_organization_policy.this
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
    nat_ip       = module.bastion_pubip.addresses[0]
    network_tier = "STANDARD"
  }]

  depends_on = [
    module.instance_template, module.bastion_pubip, google_project_organization_policy.this
  ]
}

resource "google_project_iam_member" "bastion_gke" {
  project = var.project_id
  role    = "roles/container.developer"
  member  = "serviceAccount:${google_service_account.default.email}"
}

data "template_file" "bastion_install_template" {
  template = file("scripts/bastion_setup.sh")
}

module "bastion_pubip" {

  source  = "terraform-google-modules/address/google"
  version = "~> 3.1"

  project_id       = var.project_id
  region           = var.region
  network_tier     = "STANDARD"
  address_type     = "EXTERNAL"
  subnetwork       = ""
  enable_cloud_dns = true
  dns_project      = var.project_id
  dns_domain       = "${local.default_name}.${var.domain_name}"
  dns_managed_zone = module.dns-public-zone.name

  names = [
    "bastion-external-ip",
  ]

  dns_short_names = [
    "bastion"
  ]

  depends_on = [module.dns-public-zone, google_project_organization_policy.this]
}

resource "tls_private_key" "bastion_ssh_keys" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "google_secret_manager_secret" "bastion_private_key" {
  secret_id = "${local.default_name}-bastion-private-key"
  project   = var.project_id
  labels = {
    name = "${local.default_name}-bastion-private-key",
  }

  replication {
    user_managed {
      replicas {
        location = var.region
      }
    }
  }
}

resource "google_secret_manager_secret_version" "bastion_ssh_keys" {
  secret      = google_secret_manager_secret.bastion_private_key.id
  secret_data = tls_private_key.bastion_ssh_keys.private_key_pem
}