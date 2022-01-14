provider "google" {
  project = "padok-lab"
  region  = "europe-west1"
  zone    = "europe-west1-b"
}

data "google_project" "this" {}

locals {
  domain_name = "simplestaticfrontend.padok.cloud"
}

# --- Generate Certificate --- #
resource "google_compute_managed_ssl_certificate" "this" {
  project = data.google_project.this.project_id

  name = replace(local.domain_name, ".", "-")
  managed {
    domains = [local.domain_name]
  }
}

# --- Provision load balancer --- #
module "loadbalancer" {
  source = "git@github.com:padok-team/terraform-google-lb.git?ref=376a847"

  name = replace(local.domain_name, ".", "-")
  buckets_backends = {
    frontend = {
      hosts = [local.domain_name]
      path_rules = [
        {
          paths = ["/*"]
        }
      ]
      bucket_name = module.frontend.bucket.name
    }
  }
  service_backends = {}
  ssl_certificates = [google_compute_managed_ssl_certificate.this.id]
}

# --- Deploy frontend --- #
module "frontend" {
  source   = "../.."
  name     = "simplestaticfrontend"
  location = "europe-west1"
}
