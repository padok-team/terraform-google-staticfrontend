provider "google" {
  region = "europe-west1"
  zone   = "europe-west1-b"
}

locals {
  domain_name = "simplestaticfrontend.padok.cloud"
  project_id  = "padok-cloud-factory"
}

# --- Generate Certificate --- #
resource "google_compute_managed_ssl_certificate" "this" {
  project = local.project_id

  name = replace(local.domain_name, ".", "-")
  managed {
    domains = [local.domain_name]
  }
}

# --- Provision load balancer --- #
module "loadbalancer" {
  source = "github.com/padok-team/terraform-google-lb?ref=v1.4.0"

  name       = replace(local.domain_name, ".", "-")
  project_id = local.project_id
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
  source     = "../.."
  name       = "simplestaticfrontend"
  location   = "europe-west1"
  project_id = local.project_id
}
