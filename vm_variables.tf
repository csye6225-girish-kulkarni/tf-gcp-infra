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
  default     = "projects/cloud-csye6225-dev/global/images/webapp-image-20240220024526"
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
  default     = ["webapp-service"]
}

variable "network_tier" {
  description = "The network tier for the VM"
  default     = "STANDARD"
}