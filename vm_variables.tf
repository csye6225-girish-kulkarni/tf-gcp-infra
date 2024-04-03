variable "instance_name" {
  description = "The name of the instance"
  default     = "webapp-instance"
}

variable "machine_type" {
  description = "The machine type of the instance"
  default     = "e2-small"
}

variable "boot_disk_image" {
  description = "The boot disk image for the instance"
  default     = "projects/cloud-csye6225-dev/global/images/webapp-image-20240402234336"
}

variable "boot_disk_type" {
  description = "The boot disk type for the instance"
  default     = "pd-balanced"
}

variable "boot_disk_size" {
  description = "The boot disk size for the instance"
  default     = "100"
}

variable "vm_zone" {
  description = "The zone of the instance"
  default     = "us-east1-b"
}

variable "vm_tags" {
  description = "The tags for the VM"
  default     = ["webapp-service", "db-access"]
}

variable "network_tier" {
  description = "The network tier for the VM"
  default     = "STANDARD"
}

variable "startup_script" {
  description = "The startup script for the VM"
  default     = "./scripts/web_server.sh"
}

output "db_instance_connection_name" {
  value       = google_sql_database_instance.db_instance.connection_name
  description = "The connection name of the CloudSQL instance"
}

variable "db_instance_name" {
  description = "The name of the database instance"
  default     = "webappdb"
}

variable "database_version" {
  description = "The version of the database"
  default     = "POSTGRES_13"
}

variable "tier" {
  description = "The tier of the database instance"
  default     = "db-f1-micro"
}

variable "availability_type" {
  description = "The availability type of the database instance"
  default     = "REGIONAL"
}

variable "disk_type" {
  description = "The disk type for the database instance"
  default     = "pd-ssd"
}

variable "scopes" {
  description = "The scopes for the service account"
  type        = list(string)
  default     = [
    "https://www.googleapis.com/auth/monitoring.write",
    "https://www.googleapis.com/auth/logging.admin",
    "https://www.googleapis.com/auth/pubsub"
  ]
}

variable "dns_name" {
  description = "The DNS name for the A record"
  type        = string
  default     = "girishkulkarni.me."
}

variable "ttl" {
  description = "The time to live for the DNS record"
  type        = number
  default     = 300
}

variable "managed_zone" {
  description = "The managed zone for the DNS record"
  type        = string
  default     = "girish-kulkarni-me"
}

variable "max_replicas" {
  description = "The maximum number of replicas for autoscaling"
  default     = 3
}

variable "min_replicas" {
  description = "The minimum number of replicas for autoscaling"
  default     = 1
}

variable "cooldown_period" {
  description = "The cooldown period for autoscaling"
  default     = 60
}

variable "cpu_utilization_target" {
  description = "The target CPU utilization for autoscaling"
  default     = 0.05
}

variable "hosts" {
  description = "The hosts for the URL map"
  type        = list(string)
  default     = ["girishkulkarni.me"]
}

variable "path_matcher" {
  description = "The path matcher for the URL map"
  default     = "allpaths"
}

variable "ssl_cert_name" {
  description = "The name of the SSL certificate"
  default     = "webapp-cert"
}

variable "domains" {
  description = "The domains for the managed SSL certificate"
  type        = list(string)
  default     = ["girishkulkarni.me."]
}

variable "balancing_mode" {
  description = "The balancing mode for the backend service."
  type        = string
  default     = "UTILIZATION"
}

variable "capacity_scaler" {
  description = "The capacity scaler for the backend service."
  type        = number
  default     = 1.0
}

variable "max_utilization" {
  description = "The maximum utilization for the backend service."
  type        = number
  default     = 0.05
}