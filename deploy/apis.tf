resource "google_project_service" "cloud_run" {
  service            = "run.googleapis.com"
  disable_on_destroy = true
  # defaults to true, but this person (https://github.com/Lioric/go-cloud/blob/0a3580612654e801b29df8d786d64f53da227867/samples/guestbook/gcp/main.tf) set it to true
  disable_dependent_services = true
  # depends_on = [google_project_service.cloud_resource_manager]
  # https://github.com/nishantnasa/terragrunt-modules-gcp/blob/faa4510a46baf46e8d673b48d61eff157ecb4ac5/project_config/project_services/main.tf
}

# for API gateway - https://cloud.google.com/api-gateway/docs/configure-dev-env#enabling_required_services
resource "google_project_service" "api_gateway" {
  service                    = "apigateway.googleapis.com"
  disable_on_destroy         = false
  disable_dependent_services = false
}

resource "google_project_service" "service_management" {
  service                    = "servicemanagement.googleapis.com"
  disable_on_destroy         = true
  disable_dependent_services = true
}
resource "google_project_service" "service_control" {
  service                    = "servicecontrol.googleapis.com"
  disable_on_destroy         = true
  disable_dependent_services = true
}

resource "google_project_service" "rasbign_lib_api" {
  service = google_api_gateway_api.rasbign_config.managed_service

  timeouts {
    create = "30m"
    update = "40m"
  }
  disable_on_destroy         = true
  disable_dependent_services = true
  depends_on                 = [google_api_gateway_gateway.api_gw]
}