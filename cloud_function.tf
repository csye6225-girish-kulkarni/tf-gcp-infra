# Create a Google Cloud Storage bucket
resource "google_storage_bucket" "bucket" {
  name     = var.bucket_name
  location = var.bucket_location
  uniform_bucket_level_access = true
  storage_class = "REGIONAL"

  encryption {
    default_kms_key_name = google_kms_crypto_key.bucket_crypto_key.id
  }
  depends_on = [
    google_kms_crypto_key_iam_binding.bucket_crypto_key_iam_binding
  ]
}

#resource "google_storage_bucket_iam_member" "bucket_iam_member" {
#  bucket = "email_verification_cloud"
#  role   = "roles/storage.objectAdmin"
#
#  member = "serviceAccount:${google_service_account.service_account.email}"
#}

resource "google_storage_bucket_object" "archive" {
   name   = var.object_name
  bucket = google_storage_bucket.bucket.name
  source = var.source_file
}

# Create a Google Cloud Function 2nd gen
resource "google_cloudfunctions2_function" "function" {
  name        = var.function_name
  location    = var.zone
  description = var.function_description

  build_config {
    runtime     = var.runtime
    entry_point = var.entry_point
    source {
      storage_source {
        bucket = google_storage_bucket.bucket.name
        object = google_storage_bucket_object.archive.name
      }
    }
  }

  service_config {
    max_instance_count = 1
    min_instance_count = 0
    available_memory   = "256M"
    timeout_seconds    = 60
    service_account_email = google_service_account.service_account.email
    ingress_settings = "ALLOW_INTERNAL_ONLY"
    all_traffic_on_latest_revision = true
    vpc_connector = google_vpc_access_connector.vpc_connector.name
    environment_variables = {
      "DB_CONN_STR_FUNC" = local.connection_string
      "MAILGUN_API_KEY" = var.mailgun_api_key
      "MAILGUN_DOMAIN" = var.mailgun_domain
    }
  }

  event_trigger {
    trigger_region = var.zone
    event_type     = "google.cloud.pubsub.topic.v1.messagePublished"
    pubsub_topic   = google_pubsub_topic.verify_email.id
    retry_policy   = "RETRY_POLICY_RETRY"
  }

    depends_on = [
    google_storage_bucket.bucket
  ]
}

# IAM entry for Pub/Sub to invoke the function
resource "google_cloud_run_service_iam_binding" "invoker" {
  project        = google_cloudfunctions2_function.function.project
  location         = google_cloudfunctions2_function.function.location
  service = google_cloudfunctions2_function.function.name

  role   = "roles/run.invoker"
  members = ["serviceAccount:${google_cloudfunctions2_function.function.service_config[0].service_account_email}"]
}