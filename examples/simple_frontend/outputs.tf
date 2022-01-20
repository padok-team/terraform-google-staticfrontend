output "bucket_name" {
  description = "Name of the bucket to store static web files"
  value       = module.frontend.bucket.name
}

output "domain_name" {
  description = "Domain name of static frontend"
  value       = local.domain_name
}
