data "google_compute_image" "ubuntu" {
  family  = "ubuntu-2204-lts"
  project = "ubuntu-os-cloud"
}


resource "google_compute_instance" "web_server" {
  depends_on = [google_compute_subnetwork.subnet_internal,google_compute_subnetwork.subnet_external]
  name         = "terraform-web-server"
  machine_type = "n1-standard-4"
  project = var.project_id
  zone  = "europe-west1-b"

  

  boot_disk {
    initialize_params {
      image = data.google_compute_image.ubuntu.self_link
    }
  }

  network_interface {


    network            = var.vpc_out
    subnetwork         = var.subnet_out    
  }

  network_interface {

    network            = var.vpc_in
    subnetwork         = var.subnet_in    
  }

    metadata = {        
        ssh-keys          = "cloud-user:${file(var.ssh_public_key)}"
        #user-data         = <<-EOF
        #                        #!/bin/bash
        #                        set -e
        #                        apt update
        #                        apt install -y nginx
        #                      EOF
    
    }
}