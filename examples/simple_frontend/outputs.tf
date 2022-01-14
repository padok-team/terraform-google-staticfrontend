output "certificate" {
  value = google_compute_managed_ssl_certificate.this
}

output "load_balancer_ip" {
  value = module.loadbalancer.ip_address
}
