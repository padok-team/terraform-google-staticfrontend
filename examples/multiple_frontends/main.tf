provider "google" {
  project = "padok-cloud-factory"
  region  = "europe-west1"
  zone    = "europe-west1-b"
}

data "google_project" "this" {}

locals {
  domain_name     = "padok.cloud"
  subdomain_names = ["frontend1", "frontend2"]
  hosts           = [for sub in local.subdomain_names : "${sub}.${local.domain_name}"]
  certificates = [
    google_compute_managed_ssl_certificate.this["frontend1.padok.cloud"].id,
    google_compute_managed_ssl_certificate.this["frontend2.padok.cloud"].id
  ]
}

# --- Generate Certificates --- #
resource "google_compute_managed_ssl_certificate" "this" {
  for_each = toset(local.hosts)
  project  = data.google_project.this.project_id

  name = replace(each.value, ".", "-")
  managed {
    domains = [each.value]
  }
}

# --- Provision load balancer --- #
module "loadbalancer" {
  source = "git@github.com:padok-team/terraform-google-lb.git?ref=376a847"

  name = replace(local.domain_name, ".", "-")
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
  source   = "../.."
  name     = "frontendpadok1"
  location = "europe-west1"
}

module "frontend2" {
  source   = "../.."
  name     = "frontendpadok2"
  location = "europe-west1"
}
