# create a bucket
resource "google_storage_bucket" "this" {
  name     = var.name
  project  = var.project_id
  location = var.location
  labels   = var.labels

  website {
    main_page_suffix = "index.html"
    not_found_page   = "index.html"
  }

  force_destroy = var.force_destroy

  lifecycle {
    create_before_destroy = true
  }
}

# make it public
resource "google_storage_bucket_iam_binding" "this" {
  bucket = google_storage_bucket.this.name
  role   = "roles/storage.objectViewer"
  members = [
    "allUsers",
  ]

  depends_on = [google_storage_bucket.this]

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_storage_bucket_access_control" "this" {
  bucket = google_storage_bucket.this.name
  role   = "READER"
  entity = "allUsers"

  depends_on = [google_storage_bucket.this]

  lifecycle {
    create_before_destroy = true
  }
}
