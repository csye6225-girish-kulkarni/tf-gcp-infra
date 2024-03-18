locals {
  connection_string = "postgresql://${google_sql_user.db_user.name}:${random_password.password.result}@${google_sql_database_instance.db_instance.ip_address[0].ip_address}/${google_sql_database.database.name}"
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
    EOT
  }
}

resource "google_dns_record_set" "a_record" {
  name         = "girishkulkarni.me."
  type         = "A"
  ttl          = 300
  managed_zone = "girish-kulkarni-me"
  rrdatas      = [google_compute_instance.web-server.network_interface[0].access_config[0].nat_ip]
}