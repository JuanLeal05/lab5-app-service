###############################################################################
# Laboratorio 5 - Infraestructura como codigo con Terraform (GCP)
###############################################################################

terraform {
  required_version = ">= 1.6.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
  }
}

provider "google" {
  project = var.proyecto
  region  = var.region
}

locals {
  nombre_servicio = "notas-${var.usuario}"

  etiquetas = {
    curso         = "paradigmas-de-computacion-en-la-nube"
    laboratorio   = "05-cicd-iac"
    estudiante    = var.usuario
    gestionadopor = "terraform"
  }
}

resource "google_project_service" "apis" {
  for_each = toset([
    "run.googleapis.com",
    "artifactregistry.googleapis.com",
    "iamcredentials.googleapis.com",
    "sts.googleapis.com",
  ])
  service            = each.value
  disable_on_destroy = false
}

resource "google_artifact_registry_repository" "imagenes" {
  repository_id = "lab5-${var.usuario}"
  location      = var.region
  format        = "DOCKER"
  description   = "Imagenes del portal de notas"
  labels        = local.etiquetas

  depends_on = [google_project_service.apis]
}

resource "google_cloud_run_v2_service" "app" {
  name     = local.nombre_servicio
  location = var.region
  labels   = local.etiquetas

  ingress             = "INGRESS_TRAFFIC_ALL"
  deletion_protection = false

  template {
    # Declarado exactamente igual a como GCP ya lo reporta (min=0, max=3),
    # para que config y estado coincidan y no haya diff en cada plan.
    scaling {
      min_instance_count = 0
      max_instance_count = 3
    }

    containers {
      image = var.imagen_inicial

      ports {
        container_port = 8080
      }

      resources {
        limits = {
          cpu    = "1"
          memory = "512Mi"
        }
      }

      env {
        name  = "NODE_ENV"
        value = "production"
      }
      env {
        name  = "REGION_NAME"
        value = var.region
      }
    }
  }

  lifecycle {
    ignore_changes = [
      template[0].containers[0].image,
      client,
      client_version,
    ]
  }

  depends_on = [google_project_service.apis]
}

resource "google_cloud_run_v2_service_iam_member" "publico" {
  name     = google_cloud_run_v2_service.app.name
  location = google_cloud_run_v2_service.app.location
  role     = "roles/run.invoker"
  member   = "allUsers"
}
