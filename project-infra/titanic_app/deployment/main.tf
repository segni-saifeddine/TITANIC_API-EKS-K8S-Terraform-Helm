
provider "kubernetes" {
  config_path = var.kubeconfig_path
}

resource "kubernetes_namespace" "namespace" {
  metadata {
    name = var.app_namespace
  }
}


# Documentation: https://registry.terraform.io/providers/hashicorp/helm/latest/docs
provider "helm" {
  kubernetes {
    config_path = var.kubeconfig_path
  }
  alias = "eks"
}

# Documentation: https://www.terraform.io/docs/language/settings/index.html
terraform {
  required_version = ">= 1.0.0"
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.3.0"
    }
  }
}

module "app" {

  depends_on  = [kubernetes_namespace.namespace]
  source      = "../modules"
  environment = var.environment

  postgresqlPassword = base64encode(var.postgresqlPassword)
  postgresqlUsername = base64encode(var.postgresqlUsername)
  postgresqlDatabase = base64encode(var.postgresqlDatabase)
  app_namespace      = var.app_namespace

}
