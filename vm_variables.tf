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
  default     = "projects/cloud-csye6225-dev/global/images/webapp-image-20240228191039"
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