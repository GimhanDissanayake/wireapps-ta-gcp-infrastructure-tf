provider "google" {
  project = var.project_id
  region  = var.region

  default_labels = local.default_lables
}

locals {
  default_lables = {
    project     = var.project_name
    environment = var.environment
    source      = "terraform"
  }

  default_name = "${var.project_name}-${var.short_region[var.region]}-${var.environment}"
}

resource "google_project_service" "gcp_services" {
  for_each = toset(var.gcp_service_list)

  project            = var.project_id
  service            = each.key
  disable_on_destroy = false
}