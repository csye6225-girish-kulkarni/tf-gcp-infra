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

resource "google_dns_record_set" "a_record" {
  name         = var.dns_name
  type         = "A"
  ttl          = var.ttl
  managed_zone = var.managed_zone
  rrdatas      = [google_compute_global_address.global_address.address]
}

# Compute Instance Template
resource "google_compute_region_instance_template" "web-server-template" {
  name_prefix  = var.instance_name
  machine_type = var.machine_type

  disk {
    source_image = var.boot_disk_image
    auto_delete  = true
    boot         = true
  }

  network_interface {
    network = google_compute_network.vpc.id
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

  tags = var.vm_tags

  lifecycle {
    create_before_destroy = true
  }
}

# Compute Health Check
resource "google_compute_health_check" "health_check" {
  name                = "health-check"
  check_interval_sec  = 5
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 10

  http_health_check {
    request_path = "/healthz"
    port         = 8080
  }
}

# Regional Compute Instance Group Manager
resource "google_compute_region_instance_group_manager" "instance_group_manager" {
  name               = "instance-group-manager"
  region             = var.zone
  base_instance_name = "webapp"
#  instance_template  = google_compute_instance_template.web-server-template.self_link
  target_size        = 1

  named_port {
    name = "http"
    port = 8080
  }

  auto_healing_policies {
    health_check      = google_compute_health_check.health_check.self_link
    initial_delay_sec = 300
  }

  version {
    instance_template = google_compute_region_instance_template.web-server-template.self_link
    name              = "v1"
  }

#  instance_template_tags = var.vm_tags
}

# Compute Autoscaler
resource "google_compute_region_autoscaler" "autoscaler" {
  name   = "autoscaler"
  region   = var.zone
  target = google_compute_region_instance_group_manager.instance_group_manager.self_link

  autoscaling_policy {
    max_replicas    = var.max_replicas
    min_replicas    = var.min_replicas
    cooldown_period = var.cooldown_period

    cpu_utilization {
      target = var.cpu_utilization_target
    }
  }

  depends_on = [google_compute_region_instance_group_manager.instance_group_manager]
}

# Global Address
resource "google_compute_global_address" "global_address" {
  name = "global-address"
}

# Backend Service
resource "google_compute_backend_service" "backend_service" {
  name        = "backend-service"
  port_name   = "http"
  protocol    = "HTTP"
  timeout_sec = 10

  backend {
    group = google_compute_region_instance_group_manager.instance_group_manager.instance_group
  }

  health_checks = [google_compute_health_check.health_check.self_link]
}

# URL Map
resource "google_compute_url_map" "url_map" {
  name            = "url-map"
  default_service = google_compute_backend_service.backend_service.self_link

  host_rule {
    hosts        = var.hosts
    path_matcher = var.path_matcher
  }

  path_matcher {
    name            = var.path_matcher
    default_service = google_compute_backend_service.backend_service.self_link
  }
}

resource "google_compute_managed_ssl_certificate" "default" {
  name = var.ssl_cert_name

  managed {
    domains = var.domains
  }
}

# Target HTTPs Proxy
resource "google_compute_target_https_proxy" "https_proxy" {
  name             = "https-proxy"
  url_map          = google_compute_url_map.url_map.self_link
  ssl_certificates = [google_compute_managed_ssl_certificate.default.self_link]
}
# Global Forwarding Rule
resource "google_compute_global_forwarding_rule" "http_forwarding_rule" {
  name       = "http-forwarding-rule"
  target     = google_compute_target_https_proxy.https_proxy.self_link
  ip_address = google_compute_global_address.global_address.address
  port_range = "443"
}