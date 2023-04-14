# create a bucket
resource "google_storage_bucket" "this" {
  #checkov:skip=CKV_GCP_62: ignore access logs enforcement
  #checkov:skip=CKV_GCP_114: the bucket is actually public
  name                        = var.name
  project                     = var.project_id
  location                    = var.location
  labels                      = var.labels
  uniform_bucket_level_access = var.uniform_bucket_level_access
  force_destroy               = var.force_destroy

  versioning {
    enabled = true
  }

  website {
    main_page_suffix = "index.html"
    not_found_page   = "index.html"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# make it public
resource "google_storage_bucket_iam_binding" "this" {
  #checkov:skip=CKV_GCP_28: the bucket is actually public
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
