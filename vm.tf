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
}