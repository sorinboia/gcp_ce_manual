provider "google" {
  credentials = file("./service-account-key.json")
  project = var.project_id
  region  = var.region
}
