output "bucket" {
  description = "The bucket's name"
  value       = google_storage_bucket.this.name
}
