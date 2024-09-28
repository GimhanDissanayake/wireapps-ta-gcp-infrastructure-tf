module "appvm_service_accounts" {
  count = var.create_appvm == true ? 1 : 0

  source     = "terraform-google-modules/service-accounts/google"
  version    = "~> 4.0"
  project_id = var.project_id
  prefix     = local.default_name
  names      = ["appvm-sa"]
  project_roles = [
    "${var.project_id}=>roles/storage.objectCreator"
  ]
}

module "appvm_instance_template" {
  count = var.create_appvm == true ? 1 : 0

  source  = "terraform-google-modules/vm/google//modules/instance_template"
  version = "~> 10.0"

  region               = var.region
  project_id           = var.project_id
  subnetwork           = "app-subnet-${var.region}"
  machine_type         = "e2-small"
  disk_size_gb         = 20
  source_image         = "ubuntu-2004-focal-v20231101"
  source_image_project = "ubuntu-os-cloud"
  metadata = {
    "ssh-keys" = <<EOT
      ${tls_private_key.appvm_ssh_keys.public_key_openssh}
     EOT
  }
  service_account = {
    email  = module.appvm_service_accounts[0].email
    scopes = ["cloud-platform"]
  }
  tags = ["allow-ssh-iap", "appvm"]

  startup_script = data.template_file.appvm_install_template.rendered

  depends_on = [
    module.gcp-network, module.appvm_service_accounts, google_project_organization_policy.this
  ]
}

module "appvm" {
  count = var.create_appvm == true ? 1 : 0

  source  = "terraform-google-modules/vm/google//modules/compute_instance"
  version = "~> 11.0"

  region              = var.region
  hostname            = "${local.default_name}-appvm"
  zone                = var.regional_zones[0]
  subnetwork          = "app-subnet-${var.region}"
  num_instances       = 1
  instance_template   = module.appvm_instance_template[0].self_link
  deletion_protection = false

  access_config = [{
    nat_ip       = module.appvm_pubip[0].addresses[0]
    network_tier = "STANDARD"
  }]

  depends_on = [
    module.appvm_instance_template, module.appvm_pubip, google_project_organization_policy.this
  ]
}

module "appvm_pubip" {
  count = var.create_appvm == true ? 1 : 0

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
    "appvm-external-ip",
  ]

  dns_short_names = [
    "appvm"
  ]

  depends_on = [module.dns-public-zone, google_project_organization_policy.this]
}

data "template_file" "appvm_install_template" {
  template = file("scripts/appvm_setup.sh")

  vars = {
    script1 = file("scripts/appvm_environment_steup.sh")
    script2 = file("scripts/appvm_app_steup.sh")
  }
}

resource "tls_private_key" "appvm_ssh_keys" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "google_secret_manager_secret" "appvm_private_key" {
  secret_id = "${local.default_name}-app-vm-private-key"
  project   = var.project_id
  labels = {
    name = "${local.default_name}-app-vm-private-key",
  }

  replication {
    user_managed {
      replicas {
        location = var.region
      }
    }
  }
}

resource "google_secret_manager_secret_version" "appvm_ssh_keys" {
  secret      = google_secret_manager_secret.appvm_private_key.id
  secret_data = tls_private_key.appvm_ssh_keys.private_key_pem
}