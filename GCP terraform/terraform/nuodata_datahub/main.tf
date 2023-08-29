resource "null_resource" "update_kubeconfig" {
  provisioner "local-exec" {
    interpreter = ["/bin/sh", "-c"]
    command = <<EOT
      gcloud container clusters get-credentials ${var.gke_cluster_name} --region=${var.region}
    EOT
  }
}

resource "kubernetes_namespace" "nuodata_namespace" {
  metadata {
    annotations = {
      name = "nuodata"
    }
    labels = {
      nuodata_namespace = "created-via-terraform"
    }
    name = "nuodata"
  }
}

resource "random_password" "random_user_secret" {
  length           = 16
  special          = true
  override_special = "_!%^"
}

resource "random_password" "random_auth_key" {
  length  = 32
  special = false
}

resource "kubernetes_secret" "mysql_password" {
  metadata {
    name      = "mysql-secrets"
    namespace = kubernetes_namespace.nuodata_namespace.id
  }

  data = {
    "mysql-root-password" = var.mysql_password
  }

  depends_on = [
    kubernetes_namespace.nuodata_namespace
  ]
}

resource "kubernetes_secret" "datahub_users_secret" {
  metadata {
    name      = "datahub-users-secret"
    namespace = kubernetes_namespace.nuodata_namespace.id
  }

  data = {
    "user.props" = "datahub:datahub123"
  }

  depends_on = [
    kubernetes_secret.mysql_password
  ]
}

resource "kubernetes_secret" "datahub_auth_secret" {
  metadata {
    name      = "datahub-auth-secrets"
    namespace = kubernetes_namespace.nuodata_namespace.id
    annotations = {
      "app.kubernetes.io/managed-by"   = "Helm"
      "meta.helm.sh/release-name"      = "datahub"
      "meta.helm.sh/release-namespace" = kubernetes_namespace.nuodata_namespace.id
    }
  }

  data = {
    "system_client_secret"      = base64encode(random_password.random_auth_key.result)
    "token_service_salt"        = base64encode(random_password.random_auth_key.result)
    "token_service_signing_key" = base64encode(random_password.random_auth_key.result)
  }

  depends_on = [
    kubernetes_namespace.nuodata_namespace
  ]
}
resource "helm_release" "datahub_prerequisites_release" {
  name       = "prerequisites"
  repository = "https://helm.datahubproject.io/"
  chart      = "datahub-prerequisites"
  namespace  = kubernetes_namespace.nuodata_namespace.id
  timeout    = 1000

  values = [
    file("${path.module}/prerequisites-values.yaml")
  ]

  depends_on = [
    kubernetes_secret.datahub_users_secret
  ]
}

resource "helm_release" "datahub_release" {
  name       = "datahub"
  repository = ""
  chart     = "https://github.com/acryldata/datahub-helm/releases/download/datahub-0.2.154/datahub-0.2.154.tgz"
  namespace = kubernetes_namespace.nuodata_namespace.id
  timeout   = 1000
  version   = ""
  values = [
    file("${path.module}/datahub-values.yaml")
  ]
  set {
    name  = "global.sql.datasource.host"
    value = var.sql_host
  }
  set {
    name  = "global.sql.datasource.url"
    value = var.sql_url
  }

  set {
    name  = "global.sql.datasource.username"
    value = var.sql_username
  }

  depends_on = [
    helm_release.datahub_prerequisites_release
  ]
}



