data "google_project" "project" {}

# Create a Key Ring
resource "google_kms_key_ring" "key_ring" {
  name     = "my-key-ring-${replace(timestamp(), ":", "-")}"
  provider = "google-beta"
  location = var.security_location
}

resource "google_kms_crypto_key" "vm_crypto_key" {
  name            = "vm-crypto-key"
  key_ring        = google_kms_key_ring.key_ring.id
  rotation_period = var.rotation_period
  purpose = var.purpose
  provider = "google-beta"

  lifecycle {
    prevent_destroy = false
  }
}

resource "google_kms_crypto_key_iam_binding" "vm_crypto_key_iam_binding" {
  crypto_key_id = google_kms_crypto_key.vm_crypto_key.id
  role          = var.kms_role
  provider = "google-beta"

  members       = [
    "serviceAccount:service-${data.google_project.project.number}@compute-system.iam.gserviceaccount.com",
  ]
}

resource "google_kms_crypto_key" "sql_crypto_key" {
  name            = "sql-crypto-key"
  key_ring        = google_kms_key_ring.key_ring.id
  rotation_period = var.rotation_period # 30 days in seconds
  purpose = var.purpose
  provider = "google-beta"

  lifecycle {
    prevent_destroy = false
  }
}

resource "google_kms_crypto_key_iam_binding" "sql_crypto_key_iam_binding" {
  crypto_key_id = google_kms_crypto_key.sql_crypto_key.id
  role          = var.kms_role
  provider = "google-beta"

  members       = [
    "serviceAccount:service-${data.google_project.project.number}@gcp-sa-cloud-sql.iam.gserviceaccount.com",
  ]
}

resource "google_kms_crypto_key" "bucket_crypto_key" {
  name            = "bucket-crypto-key"
  key_ring        = google_kms_key_ring.key_ring.id
  rotation_period = var.rotation_period # 30 days in seconds
  purpose = var.purpose
  provider = "google-beta"

  lifecycle {
    prevent_destroy = false
  }
}

resource "google_kms_crypto_key_iam_binding" "bucket_crypto_key_iam_binding" {
  crypto_key_id = google_kms_crypto_key.bucket_crypto_key.id
  role          = var.kms_role
  provider = "google-beta"

  members       = [
    "serviceAccount:service-${data.google_project.project.number}@gs-project-accounts.iam.gserviceaccount.com"
  ]
}

resource "google_secret_manager_secret" "vm_crypto_key_secret" {
  secret_id = var.secret_id
  project   = var.project

  labels = {
    secretmanager = "vm_crypto_key"
  }

  replication {
    user_managed {
      replicas {
        location = var.security_location
      }
    }
  }
}

resource "google_secret_manager_secret_version" "vm_crypto_key_secret_version" {
  secret      = google_secret_manager_secret.vm_crypto_key_secret.id
  secret_data = google_kms_crypto_key.vm_crypto_key.id
}