
resource "random_id" "random" {
  keepers = {
    # Generate a new id each time we switch to a new AMI id
    ami_id = var.ami_id
  }

  byte_length = 8
}

# resource "google_cloud_run_service" "rasbign" {
#   name     = "rabign-cloudrun"
#   location = var.location
#   provider = google
#   template {
#     spec {
#       containers {
#         #image = "ghcr.io/puppeteer/puppeteer:latest"
#         image = "gcr.io/google-samples/hello-app:1.0"
#       }
#       container_concurrency = 1
#       timeout_seconds       = "300s"
#     }
#     metadata {
#       annotations = {
#         "autoscaling.knative.dev/maxScale" = "1"
#       }
#     }
#   }
#   traffic {
#     percent         = 100
#     latest_revision = true
#   }
#   depends_on                 = [google_project_service.cloud_run]
#   autogenerate_revision_name = true

# }

resource "google_cloud_run_v2_service" "rasbign" {
  name     = "rabign-cloudrun"
  location = var.location
  ingress  = "INGRESS_TRAFFIC_ALL"

  template {
    containers {
      # image = "us-docker.pkg.dev/cloudrun/container/hello"
      image = "docker.io/alekslario/rasbign:latest"
      resources {
        limits = {
          cpu    = "1"
          memory = "2Gi"
        }
      }
      # forcing to use the latest image
      env {
        name  = "image_version"
        value = var.image_version
      }

      env {
        name  = "DISCORD_PASSWORD"
        value = var.discord_password
      }

      env {
        name  = "DISCORD_EMAIL"
        value = var.discord_email
      }

      env {
        name  = "DISCORD_SERVER_NAME"
        value = var.discord_server_name
      }

      env {
        name  = "CAPTCHA_API_KEY"
        value = var.captcha_api_key
      }
    }
    scaling {
      max_instance_count = 1
    }
    timeout                          = "300s"
    execution_environment            = "EXECUTION_ENVIRONMENT_GEN1"
    max_instance_request_concurrency = 1
  }
  traffic {
    type    = "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST"
    percent = 100
  }
  depends_on = [google_project_service.cloud_run]
}

resource "google_api_gateway_api" "rasbign_config" {
  depends_on = [
    google_cloud_run_v2_service.rasbign,
    google_project_service.api_gateway,
    google_project_service.service_management,
    google_project_service.service_control
  ]
  provider = google-beta
  api_id   = "rasbign-api-${random_id.random.hex}"
}

resource "google_api_gateway_api_config" "rasbign_config" {
  provider = google-beta

  depends_on    = [google_api_gateway_api.rasbign_config]
  api           = google_api_gateway_api.rasbign_config.api_id
  api_config_id = "rasbign-config-${random_id.random.hex}"

  openapi_documents {
    document {
      path     = "config/openapi.yaml"
      contents = base64encode(templatefile("config/openapi.yaml", { cloudrun_service_url = google_cloud_run_v2_service.rasbign.uri }))
    }
  }
  # lifecycle {
  #   create_before_destroy = true
  # }
}

resource "google_api_gateway_gateway" "api_gw" {
  provider   = google-beta
  api_config = google_api_gateway_api_config.rasbign_config.id
  depends_on = [google_api_gateway_api_config.rasbign_config]

  gateway_id = "rasbign-gateway-${random_id.random.hex}"

}