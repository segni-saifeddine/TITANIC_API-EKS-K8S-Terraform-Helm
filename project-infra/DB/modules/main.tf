// Postgresql Dev

resource "kubernetes_namespace" "namespace" {
  metadata {
    name = "db"
  }
}

resource "helm_release" "postgresql_dev" {
  count      = var.enable_ha == false ? 1 : 0
  name       = "bitnami"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "postgresql"
  namespace  = kubernetes_namespace.namespace.metadata[0].name

  set_sensitive {
    name  = "global.postgresql.postgresqlPassword"
    value = var.postgresqlPassword
  }

  set_sensitive {
    name  = "global.postgresql.postgresqlUsername"
    value = var.postgresqlUsername
  }

  set_sensitive {
    name  = "global.postgresql.postgresqlDatabase"
    value = var.postgresqlDatabase
  }

}

// Postgresql Prod
// Enable HA Mode

resource "helm_release" "postgresql_prod" {
  count      = var.enable_ha == true ? 1 : 0
  name       = "bitnami"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "postgresql-ha"

  set_sensitive {
    name  = "global.postgresql.password"
    value = var.postgresqlPassword
  }

  set_sensitive {
    name  = "global.postgresql.username"
    value = var.postgresqlUsername
  }

  set_sensitive {
    name  = "global.postgresql.database"
    value = var.postgresqlDatabase
  }
}