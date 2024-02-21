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
}

resource "google_compute_subnetwork" "db_subnet" {
  name          = var.db_subnet_name
  ip_cidr_range = var.db_subnet_cidr
  region        = var.zone
  network       = google_compute_network.vpc.id
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

  source_ranges = var.http_permissions_source_ranges
}

resource "google_compute_firewall" "deny_ssh" {
  name    = var.deny_ssh_name
  network = google_compute_network.vpc.name

  deny {
    protocol = var.deny_ssh_protocol
    ports    = var.deny_ssh_ports
  }

  source_ranges = var.deny_ssh_source_ranges
}