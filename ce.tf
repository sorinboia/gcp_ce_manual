resource "google_compute_instance_template" "ce_template" {
  depends_on = [google_compute_subnetwork.subnet_internal,google_compute_subnetwork.subnet_external]
  machine_type = "n1-standard-4"
    
  name_prefix   = "ce-template-"  

  disk {
    auto_delete  = true
    boot         = true    
    disk_size_gb = 50
    disk_type    = "pd-standard"
    interface    = "SCSI"

    mode         = "READ_WRITE"
    source_image = "projects/f5-gcs-4261-sales-emea-sa/global/images/rhel9-20230922033926-multi-voltmesh-eu"
    type         = "PERSISTENT"
  }

  

  metadata = {    
    VmDnsSetting      = "ZonalPreferred"
    ssh-keys          = "centos:${file(var.ssh_public_key)}"
    user-data         = data.template_file.ce_user_data.rendered    
  }

  service_account {
    email  = "920765678988-compute@developer.gserviceaccount.com"
    scopes = ["cloud-platform"]
  }
  

  network_interface {
    access_config {
      network_tier = "PREMIUM"
    }

    network            = var.vpc_out
    subnetwork         = var.subnet_out
    subnetwork_project = var.project_id
  }

  network_interface {
    network            = var.vpc_in
    subnetwork         = var.subnet_in
    subnetwork_project = var.project_id
  }

  project = var.project_id
  region  = var.region
  
}

resource "google_compute_region_instance_group_manager" "instance_group_manager" {
  name                      = local.ce_cluster_name
  region                    = var.region
  description               = "Instance group manager for CE"
  target_size               = length(local.f5xc_cluster_node_azs)
  base_instance_name        = local.ce_cluster_name
  wait_for_instances        = true
  wait_for_instances_status = "STABLE"
  distribution_policy_zones = local.f5xc_cluster_node_azs

  version {
    instance_template = google_compute_instance_template.ce_template.id
  }

  update_policy {
    type                         = "OPPORTUNISTIC"
    minimal_action               = "RESTART"
    max_surge_fixed              = length(local.f5xc_cluster_node_azs)
    max_unavailable_fixed        = length(local.f5xc_cluster_node_azs)
    instance_redistribution_type = "NONE"
  }
}


/*

resource "google_compute_instance_from_template" "ce1" {
  name           = "ce-1"
  zone           = "${var.region}-b"
  source_instance_template = google_compute_instance_template.ce_template.id  
}


resource "google_compute_instance_from_template" "ce2" {
  name           = "ce-2"
  zone           = "${var.region}-c"
  source_instance_template = google_compute_instance_template.ce_template.id  
}

resource "google_compute_instance_from_template" "ce3" {
  name           = "ce-3"
  zone           = "${var.region}-d"
  source_instance_template = google_compute_instance_template.ce_template.id  
}
*/