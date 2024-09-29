# wireapps-ta-gcp-infrastructure-tf
Wireapps Technical Assessment GCP Infrastructure Deployment using Terraform

# Infra details

* VPC
* GKE
* Bastion VM
* CloudSQL - pgsql
* CloudDNS
* Secret Manager
* Service accounts

## Setup guide

* Authenticate with gcloud for local apply
  ```sh
  gcloud auth application-default login
  ```

* create tfvars file with variables

* Use make file to apply create infra
  ```sh
  make plan
  make apply
  ```

* Flux [bootstrap](./clusters/README.md)  

# TF Docs

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.7 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | 5.44.1 |
| <a name="provider_template"></a> [template](#provider\_template) | 2.2.0 |
| <a name="provider_tls"></a> [tls](#provider\_tls) | 4.0.6 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_appvm"></a> [appvm](#module\_appvm) | terraform-google-modules/vm/google//modules/compute_instance | ~> 11.0 |
| <a name="module_appvm_instance_template"></a> [appvm\_instance\_template](#module\_appvm\_instance\_template) | terraform-google-modules/vm/google//modules/instance_template | ~> 10.0 |
| <a name="module_appvm_pubip"></a> [appvm\_pubip](#module\_appvm\_pubip) | terraform-google-modules/address/google | ~> 3.1 |
| <a name="module_appvm_service_accounts"></a> [appvm\_service\_accounts](#module\_appvm\_service\_accounts) | terraform-google-modules/service-accounts/google | ~> 4.0 |
| <a name="module_bastion_pubip"></a> [bastion\_pubip](#module\_bastion\_pubip) | terraform-google-modules/address/google | ~> 3.1 |
| <a name="module_bastion_service_account"></a> [bastion\_service\_account](#module\_bastion\_service\_account) | terraform-google-modules/service-accounts/google | ~> 4.0 |
| <a name="module_cloud-nat"></a> [cloud-nat](#module\_cloud-nat) | terraform-google-modules/cloud-nat/google | ~> 5.0 |
| <a name="module_compute_instance"></a> [compute\_instance](#module\_compute\_instance) | terraform-google-modules/vm/google//modules/compute_instance | ~> 11.0 |
| <a name="module_dns-public-zone"></a> [dns-public-zone](#module\_dns-public-zone) | terraform-google-modules/cloud-dns/google | ~> 5.0 |
| <a name="module_gcp-network"></a> [gcp-network](#module\_gcp-network) | terraform-google-modules/network/google | >= 9.0 |
| <a name="module_gke"></a> [gke](#module\_gke) | terraform-google-modules/kubernetes-engine/google//modules/private-cluster | ~> 30.0 |
| <a name="module_instance_template"></a> [instance\_template](#module\_instance\_template) | terraform-google-modules/vm/google//modules/instance_template | ~> 11.0 |
| <a name="module_pg"></a> [pg](#module\_pg) | terraform-google-modules/sql-db/google//modules/postgresql | ~> 20.0 |
| <a name="module_private-service-access"></a> [private-service-access](#module\_private-service-access) | terraform-google-modules/sql-db/google//modules/private_service_access | ~> 20.0 |

## Resources

| Name | Type |
|------|------|
| [google_artifact_registry_repository.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/artifact_registry_repository) | resource |
| [google_compute_address.ingress_lb_static](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address) | resource |
| [google_compute_router.router](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router) | resource |
| [google_project_iam_binding.dns_iam](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_binding) | resource |
| [google_project_iam_custom_role.dns](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_custom_role) | resource |
| [google_project_iam_member.bastion_gke](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_iam_member.gke_workload_iam](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_iam_member.node_gcr_sa_iam](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_organization_policy.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_organization_policy) | resource |
| [google_project_service.gcp_services](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_service) | resource |
| [google_secret_manager_secret.appvm_private_key](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret) | resource |
| [google_secret_manager_secret.bastion_private_key](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret) | resource |
| [google_secret_manager_secret_version.appvm_ssh_keys](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret_version) | resource |
| [google_secret_manager_secret_version.bastion_ssh_keys](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret_version) | resource |
| [google_service_account.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [google_service_account.dns_sa](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [google_service_account.gke_workload_sa](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [google_service_account_iam_binding.dns_wl_iam](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account_iam_binding) | resource |
| [google_service_account_iam_binding.gke_workload_iam](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account_iam_binding) | resource |
| [tls_private_key.appvm_ssh_keys](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [tls_private_key.bastion_ssh_keys](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [template_file.appvm_install_template](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |
| [template_file.bastion_install_template](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_create_appvm"></a> [create\_appvm](#input\_create\_appvm) | n/a | `bool` | `false` | no |
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name) | n/a | `string` | n/a | yes |
| <a name="input_enable_regional"></a> [enable\_regional](#input\_enable\_regional) | Enable regional cluster, default is zonal | `bool` | `false` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | n/a | `string` | n/a | yes |
| <a name="input_gcp_service_list"></a> [gcp\_service\_list](#input\_gcp\_service\_list) | List of GCP apis to be enabled | `list(string)` | <pre>[<br/>  "compute.googleapis.com",<br/>  "container.googleapis.com",<br/>  "servicenetworking.googleapis.com",<br/>  "secretmanager.googleapis.com",<br/>  "iamcredentials.googleapis.com",<br/>  "dns.googleapis.com",<br/>  "sqladmin.googleapis.com"<br/>]</pre> | no |
| <a name="input_gke_kube_version"></a> [gke\_kube\_version](#input\_gke\_kube\_version) | GKE release version | `any` | `null` | no |
| <a name="input_gke_node_pools"></a> [gke\_node\_pools](#input\_gke\_node\_pools) | GKE nodepool as list of object | `list(map(any))` | n/a | yes |
| <a name="input_ip_range_pods_name"></a> [ip\_range\_pods\_name](#input\_ip\_range\_pods\_name) | The secondary ip range to use for pods | `string` | `"gke-pods-cidr"` | no |
| <a name="input_ip_range_services_name"></a> [ip\_range\_services\_name](#input\_ip\_range\_services\_name) | The secondary ip range to use for services | `string` | `"gke-svc-cidr"` | no |
| <a name="input_k8s_apps_sa"></a> [k8s\_apps\_sa](#input\_k8s\_apps\_sa) | Service Accounts for K8s Workloads | `list(string)` | `null` | no |
| <a name="input_node_pools_taints"></a> [node\_pools\_taints](#input\_node\_pools\_taints) | node pool taints configs | `map(list(any))` | `null` | no |
| <a name="input_organization_policy_overwrite"></a> [organization\_policy\_overwrite](#input\_organization\_policy\_overwrite) | organization\_policy\_overwrite | <pre>list(object({<br/>    project    = string<br/>    constraint = string<br/>    values     = list(string)<br/>  }))</pre> | <pre>[<br/>  {<br/>    "constraint": "constraints/compute.vmExternalIpAccess",<br/>    "project": "test-project",<br/>    "values": [<br/>      "projects/test-project/zones/northamerica-northeast1-a/instances/test-vm"<br/>    ]<br/>  }<br/>]</pre> | no |
| <a name="input_pg_admin_password"></a> [pg\_admin\_password](#input\_pg\_admin\_password) | n/a | `string` | n/a | yes |
| <a name="input_pg_admin_username"></a> [pg\_admin\_username](#input\_pg\_admin\_username) | n/a | `string` | n/a | yes |
| <a name="input_pg_availability_type"></a> [pg\_availability\_type](#input\_pg\_availability\_type) | PG HA availability type REGIONAL or ZONAL. Default: ZONAL | `string` | n/a | yes |
| <a name="input_pg_retained_backups"></a> [pg\_retained\_backups](#input\_pg\_retained\_backups) | PG backup retaion days | `number` | `7` | no |
| <a name="input_pg_tier"></a> [pg\_tier](#input\_pg\_tier) | PG machine type. Format: db-custom-<CPU>-<Memory mulitple of 256MB> | `string` | `"db-custom-1-3840"` | no |
| <a name="input_postgres_db_list"></a> [postgres\_db\_list](#input\_postgres\_db\_list) | PG Database name list | `list(string)` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The project ID to host the cluster in | `any` | n/a | yes |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Project name | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | n/a | `string` | `"us-central1"` | no |
| <a name="input_regional_zones"></a> [regional\_zones](#input\_regional\_zones) | n/a | `list` | <pre>[<br/>  "us-central1-a",<br/>  "us-central1-b",<br/>  "us-central1-c"<br/>]</pre> | no |
| <a name="input_short_region"></a> [short\_region](#input\_short\_region) | n/a | `map(string)` | <pre>{<br/>  "australia-southeast1": "ause1",<br/>  "australia-southeast2": "ause2",<br/>  "northamerica-northeast1": "nane1",<br/>  "northamerica-northeast2": "nane2",<br/>  "us-central1": "usc1",<br/>  "us-east1": "use1"<br/>}</pre> | no |
| <a name="input_subnet_cidr"></a> [subnet\_cidr](#input\_subnet\_cidr) | list of cidr corresponding subnet names | `list(string)` | n/a | yes |
| <a name="input_subnet_names"></a> [subnet\_names](#input\_subnet\_names) | list of subnet names | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_appvm_external_ip"></a> [appvm\_external\_ip](#output\_appvm\_external\_ip) | n/a |
| <a name="output_bastion_external_ip"></a> [bastion\_external\_ip](#output\_bastion\_external\_ip) | n/a |
| <a name="output_dns_ns_records"></a> [dns\_ns\_records](#output\_dns\_ns\_records) | n/a |
| <a name="output_dns_solver_service_account"></a> [dns\_solver\_service\_account](#output\_dns\_solver\_service\_account) | n/a |
| <a name="output_gke_workload_service_account"></a> [gke\_workload\_service\_account](#output\_gke\_workload\_service\_account) | n/a |
| <a name="output_ingress_lb_static"></a> [ingress\_lb\_static](#output\_ingress\_lb\_static) | n/a |
| <a name="output_node_pool_service_account"></a> [node\_pool\_service\_account](#output\_node\_pool\_service\_account) | n/a |
| <a name="output_postgres_db_private_ip"></a> [postgres\_db\_private\_ip](#output\_postgres\_db\_private\_ip) | DB |