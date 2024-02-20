variable "project" {
  description = "The project ID to deploy into"
  default     = "cloud-vpc-terraform"
}

variable "region" {
  description = "The region to deploy into"
  default     = "us-east1"
}

variable "vpc-name" {
  description = "The name of the VPC"
  default     = "csye6225-vpc"
}

variable "routing_mode" {
  description = "The routing mode for the VPC"
  default     = "REGIONAL"
}

provider "google" {
  project = var.project
  region  = var.region
}

resource "google_compute_network" "vpc" {
  name                            = var.vpc-name
  auto_create_subnetworks         = false
  delete_default_routes_on_create = true
  routing_mode                    = var.routing_mode
}

resource "google_compute_subnetwork" "webapp_subnet" {
  name          = "webapp"
  ip_cidr_range = "10.0.1.0/24"
  region        = var.region
  network       = google_compute_network.vpc.id
}

resource "google_compute_subnetwork" "db_subnet" {
  name          = "db"
  ip_cidr_range = "10.0.2.0/24"
  region        = var.region
  network       = google_compute_network.vpc.id
}

resource "google_compute_route" "webapp_route" {
  name             = "webapp-internet-route"
  dest_range       = "0.0.0.0/0"
  network          = google_compute_network.vpc.id
  next_hop_gateway = "default-internet-gateway"
  priority         = 1000
