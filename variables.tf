variable "project_id" {
  description = "The ID of the project in which resources will be provisioned."
  default = "f5-gcs-4261-sales-emea-sa"
}




############ CE specific info #########################

variable "ce_cluster_name" {  
  default     = "sorin-gcp-manual"
}

variable "registration_token" {  
  default     = "e1df0398-3fdf-444c-b2b1-38f5fd3464b9"
}

variable "ssh_public_key" {  
  default     = "./pub.key"
}

locals {
  config_content = <<-EOT
    Vpm:
        ClusterName: ${var.ce_cluster_name}
        ClusterType: ce
        Token: ${var.registration_token}
        Latitude: 50.44816
        Longitude: 3.81886
        MauricePrivateEndpoint: https://register-tls.ves.volterra.io
        MauriceEndpoint: https://register.ves.volterra.io
        CertifiedHardwareEndpoint: https://vesio.blob.core.windows.net/releases/certified-hardware/gcp.yml

        Kubernetes:
        CloudProvider: ""
        EtcdUseTLS: True
        Server: vip        
  EOT
}

data "template_file" "ce_user_data" {
  template = file("ce_user_data.tpl")

  vars = {
    ssh_public_key     = file(var.ssh_public_key)
    config_content     = base64encode(local.config_content)    
  }
}

variable "region" {
  description = "The region where GCP resources will be created."
  default     = "europe-west1"
}

variable "vpc_in" {  
  default     = "vpc-internal"
}

variable "vpc_out" {  
  default     = "vpc-external"
}

variable "subnet_in" {  
  default     = "subnet-internal"
}

variable "subnet_out" {  
  default     = "subnet-external"
}