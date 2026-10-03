output "nombre_servicio" {
  value = google_cloud_run_v2_service.app.name
}

output "url" {
  value = google_cloud_run_v2_service.app.uri
}

output "repositorio_imagenes" {
  value = "${var.region}-docker.pkg.dev/${var.proyecto}/${google_artifact_registry_repository.imagenes.repository_id}"
}

output "region" {
  value = var.region
}
