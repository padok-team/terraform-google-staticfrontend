provider "google" {
  region = "europe-west1"
  zone   = "europe-west1-b"
}

locals {
  domain_name     = "padok.cloud"
  subdomain_names = ["frontend1", "frontend2"]
  hosts           = [for sub in local.subdomain_names : "${sub}.${local.domain_name}"]
  certificates = [
    google_compute_managed_ssl_certificate.this["frontend1.padok.cloud"].id,
    google_compute_managed_ssl_certificate.this["frontend2.padok.cloud"].id
  ]
  project_id = "padok-cloud-factory"
}

# --- Generate Certificates --- #
resource "google_compute_managed_ssl_certificate" "this" {
  for_each = toset(local.hosts)
  project  = local.project_id

  name = replace(each.value, ".", "-")
  managed {
    domains = [each.value]
  }
}

# --- Provision load balancer --- #
#checkov:skip=CKV_TF_1: "Ensure Terraform module sources use a commit hash"
module "loadbalancer" {
  source = "github.com/padok-team/terraform-google-lb?ref=v1.4.0"

  name       = replace(local.domain_name, ".", "-")
  project_id = local.project_id
  buckets_backends = {
    frontend-1 = {
      hosts = ["frontend1.padok.cloud"]
      path_rules = [
        {
          paths = ["/*"]
        }
      ]
      bucket_name = module.frontend1.bucket.name
    }
    frontend-2 = {
      hosts = ["frontend2.padok.cloud"]
      path_rules = [
        {
          paths = ["/*"]
        }
      ]
      bucket_name = module.frontend2.bucket.name
    }
  }
  service_backends = {}
  ssl_certificates = local.certificates
}

# --- Deploy frontends --- #
module "frontend1" {
  source     = "../.."
  name       = "frontendpadok1"
  location   = "europe-west1"
  project_id = local.project_id
}

module "frontend2" {
  source     = "../.."
  name       = "frontendpadok2"
  location   = "europe-west1"
  project_id = local.project_id
}
