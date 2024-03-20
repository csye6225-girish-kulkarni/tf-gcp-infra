locals {
  connection_string = "postgresql://${google_sql_user.db_user.name}:${random_password.password.result}@${google_sql_database_instance.db_instance.ip_address[0].ip_address}/${google_sql_database.database.name}"
}

resource "google_service_account" "service_account" {
  account_id   = "monitoring-agent"
  display_name = "Monitoring Account Agent"
}

resource "google_project_iam_binding" "logging_admin" {
  project = var.project
  role    = "roles/logging.admin"

  members = [
    "serviceAccount:${google_service_account.service_account.email}",
  ]

  lifecycle {
    ignore_changes = [members]
  }
}

resource "google_project_iam_binding" "monitoring_metric_writer" {
  project = var.project
  role    = "roles/monitoring.metricWriter"

  members = [
    "serviceAccount:${google_service_account.service_account.email}",
  ]

  lifecycle {
    ignore_changes = [members]
  }
}

resource "google_compute_instance" "web-server" {
  name         = var.instance_name
  machine_type = var.machine_type
  zone         = var.vm_zone
  tags         = var.vm_tags

  boot_disk {
    initialize_params {
      image = var.boot_disk_image
      size  = var.boot_disk_size
      type  = var.boot_disk_type
    }
  }

  network_interface {
    network    = google_compute_network.vpc.id
    subnetwork = google_compute_subnetwork.webapp_subnet.id

    access_config {
      network_tier = var.network_tier
    }
  }

  metadata = {
    startup-script = <<-EOT
    #!/bin/bash
    echo "POSTGRES_CONN_STR=${local.connection_string}" > /usr/bin/webapp.env
    sudo chown csye6225:csye6225 /usr/bin/webapp.env
    sudo chmod 644 /usr/bin/webapp.env
    touch /tmp/webapp.flag
    sudo systemctl restart webapp.service
    sudo usermod -a -G csye6225 google-logging-agent
    sudo chmod 640 /var/log/webapp/webapp.log
    sudo systemctl restart google-cloud-ops-agent
    EOT
    google-logging-enabled = "true"
  }

    service_account {
        email  = google_service_account.service_account.email
        scopes = var.scopes
    }
}

resource "google_dns_record_set" "a_record" {
  name         = var.dns_name
  type         = "A"
  ttl          = var.ttl
  managed_zone = var.managed_zone
  rrdatas      = [google_compute_instance.web-server.network_interface[0].access_config[0].nat_ip]
}

