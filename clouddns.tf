module "dns-public-zone" {
  source  = "terraform-google-modules/cloud-dns/google"
  version = "~> 5.0"

  project_id = var.project_id
  type       = "public"
  name       = "${local.default_name}-gcp-dns"
  domain     = "${local.default_name}.example.com."
}
