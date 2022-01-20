output "domain_names" {
  description = "Domain names of static frontends"
  value       = local.hosts
}

output "bucket_names" {
  description = "Name of the buckets to store static web files for each domain"
  value       = [for front in module.frontend : front.bucket.name]
}
