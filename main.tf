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

# OrgPolicies owerwrite
resource "google_project_organization_policy" "this" {
  for_each = { for idx, policy in var.organization_policy_overwrite : idx => policy }

  project    = each.value.project
  constraint = each.value.constraint

  list_policy {
    allow {
      values = each.value.values
    }
  }
}