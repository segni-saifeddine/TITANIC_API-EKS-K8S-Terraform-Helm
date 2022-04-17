
variable "postgresqlPassword" {
  description = "postgresql Password"
  type        = string
}

variable "postgresqlUsername" {
  description = "postgresql Username"
  type        = string
}

variable "postgresqlDatabase" {
  description = "postgresql Database"
  type        = string
}

variable "environment" {
  description = "environment name"
  type        = string
}

variable "kubeconfig_path" {
  description = "eks kubeconfig path"
  type        = string
}

variable "app_namespace" {
  description = "namespace for app"
  type        = string
  default     = "app"
}