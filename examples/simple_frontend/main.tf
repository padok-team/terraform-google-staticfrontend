provider "google" {
  project = "padok-lab"
  region  = "europe-west1"
  zone    = "europe-west1-b"
}

data "google_project" "this" {}

locals {
  domain_name = "${var.namespace}-staticfrontend.k8s-training.padok.cloud"
}

# --- DNS Record --- #
resource "google_dns_record_set" "this" {
  managed_zone = "padok-k8s-training"
  name         = "${local.domain_name}."
  type         = "A"
  rrdatas      = [module.loadbalancer.ip_address]
  ttl          = 10
}

# --- TLS Certificate --- #
resource "tls_private_key" "this" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "tls_self_signed_cert" "this" {
  key_algorithm   = tls_private_key.this.algorithm
  private_key_pem = tls_private_key.this.private_key_pem

  # Certificate expires after 2 hours.
  validity_period_hours = 2

  # Reasonable set of uses for a server SSL certificate.
  allowed_uses = [
    "key_encipherment",
    "digital_signature",
  ]

  dns_names = [local.domain_name]

  subject {
    common_name  = local.domain_name
    organization = "Padok"
  }
}

resource "google_compute_ssl_certificate" "this" {
  project = data.google_project.this.project_id

  name        = replace(local.domain_name, ".", "-")
  private_key = tls_private_key.this.private_key_pem
  certificate = tls_self_signed_cert.this.cert_pem

  lifecycle {
    create_before_destroy = true
  }
}

# --- Provision load balancer --- #
module "loadbalancer" {
  source = "git@github.com:padok-team/terraform-google-lb.git?ref=v1.0.1"

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
  ssl_certificates = [google_compute_ssl_certificate.this.id]
}

# --- Deploy frontend --- #
module "frontend" {
  source        = "../.."
  name          = "${var.namespace}-staticfrontend"
  location      = "europe-west1"
  force_destroy = true
}
