output "hostname" {
  value = google_api_gateway_gateway.api_gw.default_hostname
}

output "cloud_run_url" {
  value = google_cloud_run_v2_service.rasbign.uri
  # status is a list with a single object inside - https://www.terraform.io/docs/language/expressions/types.html#indices-and-attributes - entire status list below
}