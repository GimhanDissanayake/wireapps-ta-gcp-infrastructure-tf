module "gke" {
  source  = "terraform-google-modules/kubernetes-engine/google//modules/private-cluster"
  version = "~> 30.0"

  project_id              = var.project_id
  name                    = "${local.default_name}-gke"
  regional                = var.enable_regional
  zones                   = var.regional_zones
  region                  = var.region
  network                 = module.gcp-network.network_name
  subnetwork              = "gke-subnet-${var.region}"
  ip_range_pods           = var.ip_range_pods_name
  ip_range_services       = var.ip_range_services_name
  master_ipv4_cidr_block  = "172.16.0.0/28"
  enable_private_endpoint = false
  enable_private_nodes    = true
  create_service_account  = true
  deletion_protection     = false
  release_channel         = "UNSPECIFIED"
  kubernetes_version      = var.gke_kube_version

  remove_default_node_pool = true
  logging_service          = "none"

  node_pools             = var.gke_node_pools
  maintenance_start_time = "1970-01-01T15:30:00Z"
  maintenance_recurrence = "FREQ=WEEKLY;BYDAY=SA,SU"
  maintenance_end_time   = "1970-01-01T21:30:00Z"

  master_authorized_networks = [
    {
      cidr_block   = module.gcp-network.subnets["${var.region}/bastion-subnet-${var.region}"].ip_cidr_range
      display_name = "VPC"
    },
    {
      cidr_block   = "${module.bastion_pubip.addresses[0]}/32"
      display_name = "Bastion Github Action Self Hosted Runner"
    }
  ]

  node_pools_taints = var.node_pools_taints

  depends_on = [
    module.gcp-network,
    google_project_service.gcp_services
  ]
}

resource "google_project_iam_member" "node_gcr_sa_iam" {
  for_each = toset(["roles/artifactregistry.reader", "roles/storage.objectCreator", "roles/storage.objectViewer"])

  project = var.project_id
  role    = each.key
  member  = "serviceAccount:${module.gke.service_account}"
}

# service account for GKE api workloads
resource "google_service_account" "gke_workload_sa" {
  account_id   = "${local.default_name}-gke-workload"
  display_name = "gke-workload"

  depends_on = [
    module.gke
  ]
}

resource "google_project_iam_member" "gke_workload_iam" {
  for_each = toset(["roles/secretmanager.secretAccessor", "roles/storage.objectCreator", "roles/storage.objectViewer", "roles/storage.objectUser"])

  project = var.project_id
  role    = each.key
  member  = "serviceAccount:${google_service_account.gke_workload_sa.email}"
}

resource "google_service_account_iam_binding" "gke_workload_iam" {
  service_account_id = google_service_account.gke_workload_sa.id
  role               = "roles/iam.workloadIdentityUser"

  members = flatten([
    [
      for item in var.k8s_apps_sa : "serviceAccount:${var.project_id}.svc.id.goog[${item}]"
    ]
  ])

  depends_on = [
    google_service_account.gke_workload_sa,
    module.gke
  ]
}

resource "google_artifact_registry_repository" "this" {
  location      = var.region
  repository_id = "${local.default_name}-docker-repository"
  description   = "${local.default_name}-docker-repository"
  format        = "DOCKER"

  docker_config {
    immutable_tags = true
  }
}

resource "google_service_account" "dns_sa" {
  account_id   = "${local.default_name}-dns-solver"
  display_name = "ingress-dns-solver"

  depends_on = [
    module.gke
  ]
}

resource "google_project_iam_custom_role" "dns" {
  role_id     = "dnsSolverRole"
  title       = "dns-solver-role"
  description = "dns solver role used for certmanager"
  permissions = [
    "dns.resourceRecordSets.create", "dns.resourceRecordSets.update", "dns.resourceRecordSets.delete", "dns.resourceRecordSets.get", "dns.resourceRecordSets.list",
    "dns.changes.create", "dns.changes.get", "dns.changes.list",
    "dns.managedZones.list"
  ]
}

resource "google_project_iam_binding" "dns_iam" {
  project = var.project_id
  role    = google_project_iam_custom_role.dns.id

  members = [
    "serviceAccount:${google_service_account.dns_sa.email}"
  ]
}

resource "google_service_account_iam_binding" "dns_wl_iam" {
  service_account_id = google_service_account.dns_sa.id
  role               = "roles/iam.workloadIdentityUser"

  members = [
    "serviceAccount:${var.project_id}.svc.id.goog[cert-manager/cert-manager]"
  ]

  depends_on = [
    google_service_account.dns_sa,
    module.gke
  ]
}