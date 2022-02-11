provider "google" {
  project = "padok-lab"
  region  = "europe-west1"
  zone    = "europe-west1-b"
}

data "google_project" "this" {}

locals {
  domain_name     = "k8s-training.padok.cloud"
  subdomain_names = ["${var.namespace}-frontend1", "${var.namespace}-frontend2"]
  hosts           = [for sub in local.subdomain_names : "${sub}.${local.domain_name}"]
}

# --- DNS Record --- #
resource "google_dns_record_set" "this" {
  for_each = toset(local.hosts)

  managed_zone = "padok-k8s-training"
  name         = "${each.value}."
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

  dns_names = local.hosts

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
  buckets_backends = { for k, name in local.subdomain_names : name => {
    hosts = [local.hosts[k]]
    path_rules = [
      {
        paths = ["/*"]
      }
    ]
    bucket_name = module.frontend[name].bucket.name
  } }
  service_backends = {}
  ssl_certificates = [google_compute_ssl_certificate.this.id]
}

# --- Deploy frontends --- #
module "frontend" {
  for_each = toset(local.subdomain_names)

  source        = "../.."
  name          = "${each.value}-staticfrontend"
  location      = "europe-west1"
  force_destroy = true
}
