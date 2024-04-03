variable "project" {
  description = "The project ID to deploy into"
  default     = "cloud-csye6225-dev"
}

variable "zone" {
  description = "The zone to deploy into"
  default     = "us-east1"
}

variable "vpc-name" {
  description = "The name of the VPC"
  default     = "csye6225-vpc-dev"
}

variable "routing_mode" {
  description = "The routing mode for the VPC"
  default     = "REGIONAL"
}

variable "webapp_subnet_cidr" {
  description = "The IP CIDR range for the webapp subnet"
  default     = "10.0.1.0/24"
}

variable "db_subnet_cidr" {
  description = "The IP CIDR range for the database subnet"
  default     = "10.0.2.0/24"
}

variable "webapp_subnet_name" {
  description = "The name of the webapp subnet"
  default     = "webapp"
}

variable "db_subnet_name" {
  description = "The name of the webapp subnet"
  default     = "db"
}

variable "webapp_route_name" {
  description = "The name of the webapp route"
  default     = "webapp-internet-route"
}

variable "dest_range" {
  description = "The destination range for the webapp route"
  default     = "0.0.0.0/0"
}

variable "next_hop_gateway" {
  description = "The next hop gateway for the webapp route"
  default     = "default-internet-gateway"
}

variable "priority" {
  description = "The priority for the webapp route"
  default     = 1000
}

variable "http_permissions_name" {
  description = "The name of the http permissions firewall rule"
  default     = "http-permissions"
}

variable "http_permissions_target_tags" {
  description = "The target tags for the http permissions firewall rule"
  default     = ["webapp-service"]
}

variable "http_permissions_protocol" {
  description = "The protocol for the http permissions firewall rule"
  default     = "tcp"
}

variable "http_permissions_ports" {
  description = "The ports for the http permissions firewall rule"
  default     = ["8080", "22"]
}


variable "deny_ssh_name" {
  description = "The name of the deny ssh firewall rule"
  default     = "deny-ssh"
}

variable "deny_ssh_protocol" {
  description = "The protocol for the deny ssh firewall rule"
  default     = "tcp"
}

variable "health_check_ip_range1" {
  description = "The first IP range for the health check"
  default     = "130.211.0.0/22"
}

variable "health_check_ip_range2" {
  description = "The second IP range for the health check"
  default     = "35.191.0.0/16"
}

variable "deny_ssh_ports" {
  description = "The ports for the deny ssh firewall rule"
  default     = ["22"]
}

variable "deny_ssh_source_ranges" {
  description = "The source ranges for the deny ssh firewall rule"
  default     = ["0.0.0.0/0"]
}