provider "google" {
  project = var.project
  region  = var.zone
}

resource "google_compute_network" "vpc" {
  name                            = var.vpc-name
  auto_create_subnetworks         = false
  delete_default_routes_on_create = true
  routing_mode                    = var.routing_mode
}

resource "google_compute_subnetwork" "webapp_subnet" {
  name          = var.webapp_subnet_name
  ip_cidr_range = var.webapp_subnet_cidr
  region        = var.zone
  network       = google_compute_network.vpc.id
  private_ip_google_access = true
}

resource "google_compute_subnetwork" "db_subnet" {
  name                     = var.db_subnet_name
  ip_cidr_range            = var.db_subnet_cidr
  region                   = var.zone
  network                  = google_compute_network.vpc.id
  private_ip_google_access = true
}

resource "google_compute_route" "webapp_route" {
  name             = var.webapp_route_name
  dest_range       = var.dest_range
  network          = google_compute_network.vpc.id
  next_hop_gateway = var.next_hop_gateway
  priority         = var.priority
}

resource "google_compute_firewall" "http-permissions" {
  name        = var.http_permissions_name
  network     = google_compute_network.vpc.name
  target_tags = var.http_permissions_target_tags

  allow {
    protocol = var.http_permissions_protocol
    ports    = var.http_permissions_ports
  }

  source_ranges = [google_compute_global_forwarding_rule.http_forwarding_rule.ip_address, var.health_check_ip_range1, var.health_check_ip_range2]
}

resource "google_compute_firewall" "allow_https" {
  name    = "allow-https"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

  source_ranges = [google_compute_global_forwarding_rule.http_forwarding_rule.ip_address, var.health_check_ip_range1, var.health_check_ip_range2]
}

#resource "google_compute_firewall" "allow_sql_admin_api" {
#  name    = "allow-sql-admin-api"
#  network = google_compute_network.vpc.name
#
#  allow {
#    protocol = "tcp"
#    ports    = ["443"]
#  }
#
#  direction = "EGRESS"
#  destination_ranges = ["0.0.0.0/0"]
#}

resource "google_compute_firewall" "deny_ssh" {
  name    = var.deny_ssh_name
  network = google_compute_network.vpc.name

  deny {
    protocol = var.deny_ssh_protocol
    ports    = var.deny_ssh_ports
  }

  source_ranges = var.deny_ssh_source_ranges
}

resource "google_compute_firewall" "allow_db_access" {
  name    = "allow-db-access"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["5432"] # Postgres
  }

  source_tags = ["db-access"]
}

resource "google_compute_global_address" "private_ip" {
  #  provider     = google-beta
  project       = var.project
  name          = "private-ip"
  address_type  = "INTERNAL"
  purpose       = "VPC_PEERING"
  network       = google_compute_network.vpc.self_link
  prefix_length = 16
}

resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.vpc.id
  reserved_peering_ranges = [google_compute_global_address.private_ip.name]
  service                 = "servicenetworking.googleapis.com"
  #  depends_on              = [google_compute_global_address.private_ip]
}

resource "google_sql_database_instance" "db_instance" {
  name                = var.db_instance_name
  region              = var.zone
  database_version    = var.database_version
  depends_on          = [google_service_networking_connection.private_vpc_connection]
  deletion_protection = false
  settings {
    tier              = var.tier
    availability_type = var.availability_type
    disk_type         = var.disk_type
    disk_size         = 100

    ip_configuration {
      ipv4_enabled    = false
      private_network = google_compute_network.vpc.id
    }
  }
}

resource "google_sql_database" "database" {
  instance = google_sql_database_instance.db_instance.name
  name     = "webapp"
}

resource "random_password" "password" {
  length  = 8
  special = false
}

resource "google_sql_user" "db_user" {
  name     = "webapp"
  instance = google_sql_database_instance.db_instance.name
  password = random_password.password.result
}

data "google_sql_database_instance" "db_instance" {
  name = google_sql_database_instance.db_instance.name
}

resource "google_vpc_access_connector" "vpc_connector" {
  name          = "vpc-connector"
  region        = var.zone
  network       = google_compute_network.vpc.name
  ip_cidr_range = "10.10.0.0/28"
}