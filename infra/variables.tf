variable "proyecto" {
  description = "Id del proyecto de GCP"
  type        = string
}

variable "usuario" {
  description = "Identificador corto del estudiante"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]{3,12}$", var.usuario))
    error_message = "Use entre 3 y 12 caracteres: minusculas, numeros y guiones."
  }
}

variable "region" {
  description = "Region de GCP"
  type        = string
  default     = "us-central1"
}

variable "imagen_inicial" {
  description = "Imagen con la que nace el servicio"
  type        = string
  default     = "us-docker.pkg.dev/cloudrun/container/hello"
}
