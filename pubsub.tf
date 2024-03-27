resource "google_project_iam_member" "pubsub_creator" {
  project = var.project
  role    = "roles/pubsub.editor"
  member  = "serviceAccount:${google_service_account.service_account.email}"
}

resource "google_pubsub_topic" "verify_email" {
  name = "email_verification"
}

resource "google_pubsub_topic_iam_member" "pubsub_publisher" {
  topic  = google_pubsub_topic.verify_email.name
  role   = "roles/pubsub.publisher"
  member = "serviceAccount:${google_service_account.service_account.email}"
}