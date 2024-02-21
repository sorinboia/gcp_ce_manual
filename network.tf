# Create the first VPC (external)
resource "google_compute_network" "vpc_external" {
  name                    = "vpc-external"
  auto_create_subnetworks = false
}

# Create the second VPC (internal)
resource "google_compute_network" "vpc_internal" {
  name                    = "vpc-internal"
  auto_create_subnetworks = false
}

# Subnet for the external VPC
resource "google_compute_subnetwork" "subnet_external" {
  name          = "subnet-external"
  ip_cidr_range = "10.0.1.0/24"
  region        = var.region
  network       = google_compute_network.vpc_external.id
}

# Subnet for the internal VPC
resource "google_compute_subnetwork" "subnet_internal" {
  name          = "subnet-internal"
  ip_cidr_range = "10.0.2.0/24"
  region        = var.region
  network       = google_compute_network.vpc_internal.id
}


resource "google_compute_firewall" "allow_internal_ingress" {
  name    = "tf-allow-all-ingress"
  network = google_compute_network.vpc_internal.name

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  source_ranges = ["0.0.0.0/0"]
}

# Allow all egress traffic from the subnets
resource "google_compute_firewall" "allow_internal_egress" {
  name    = "tf-allow-all-internal-egress"
  network = google_compute_network.vpc_internal.name

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  direction = "EGRESS"
  destination_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "allow_external_ingress" {
  name    = "tf-allow-all-external-ingress"
  network = google_compute_network.vpc_external.name

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  source_ranges = ["0.0.0.0/0"]
}

# Allow all egress traffic from the subnets
resource "google_compute_firewall" "allow_external_egress" {
  name    = "tf-allow-all-external-egress"
  network = google_compute_network.vpc_external.name

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  direction = "EGRESS"
  destination_ranges = ["0.0.0.0/0"]
}


resource "google_compute_router" "router" {
  name    = "my-router"
  region  = google_compute_subnetwork.subnet_external.region
  network = google_compute_network.vpc_external.id

}

resource "google_compute_router_nat" "nat" {
  name                               = "my-router-nat"
  router                             = google_compute_router.router.name
  region                             = google_compute_router.router.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

}