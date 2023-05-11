terraform {
  cloud {
    organization = "alekslario"

    workspaces {
      name = "rasbign"
    }
  }
  required_version = ">= 0.14"

}

provider "google" {
  project = var.google_cloud_project_id
  region  = var.location
}
provider "google-beta" {
  project = var.google_cloud_project_id
  region  = var.location
}