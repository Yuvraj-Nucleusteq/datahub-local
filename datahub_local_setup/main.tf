terraform {
  required_providers {
    kubernetes = {
      version = "2.15.0"
      source = "hashicorp/kubernetes"
    }

    helm = {
      source = "hashicorp/helm"
      version = "2.7.1"
    }
  }
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

resource "kubernetes_namespace" "datahub_namespace" {
  metadata {
    annotations = {
      name = "datahub"
    }
    labels = {
      datahub_namespace = "created-via-terraform"
    }
    name = "datahub"
  }

  # depends_on = [
  #   null_resource.update_kubeconfig
  # ]
}

resource "random_password" "random_master_password" {
  length           = 16
  special          = true
  override_special = "_!%^"
}

resource "random_password" "random_token" {
  length           = 32
  special          = false
  # override_special = "_!%^"
}

resource "kubernetes_secret" "mysql_password" {
  metadata {
    name = "mysql-secrets"
    namespace = kubernetes_namespace.datahub_namespace.id
  }

  data = {
    "mysql-root-password"="datahub"
  }

  depends_on = [
    kubernetes_namespace.datahub_namespace
  ]
}


resource "kubernetes_secret" "datahub_users_secret" {
  metadata {
    name = "datahub-users-secret"
    namespace = kubernetes_namespace.datahub_namespace.id
  }

  data = {
    "user.props"="datahub:datahub123"
  }

  depends_on = [
    kubernetes_secret.mysql_password
  ]
}

resource "kubernetes_secret" "auth_Secret" {
  metadata {
    name = "datahub-auth-secrets"
    namespace = kubernetes_namespace.datahub_namespace.id
    annotations = {
      "app.kubernetes.io/managed-by" = "Helm"
      "meta.helm.sh/release-name" = "datahub"
      "meta.helm.sh/release-namespace" = kubernetes_namespace.datahub_namespace.id
    }
  }

  data = {
    "system_client_secret"=base64encode(random_password.random_token.result)
    "token_service_salt"=base64encode(random_password.random_token.result)
    "token_service_signing_key"=base64encode(random_password.random_token.result)
  }

  depends_on = [
    kubernetes_namespace.datahub_namespace
  ]
}

resource "helm_release" "datahub_prerequisites_release" {
  name = "prerequisites"
  repository = ""
  chart      = "datahub-prerequisites-0.0.14.tgz"
  namespace  = kubernetes_namespace.datahub_namespace.id

  values = [
    file("${path.module}/prerequisites-values.yaml")
  ]

  depends_on = [
    kubernetes_secret.datahub_users_secret

  ]
}

resource "helm_release" "datahub_release" {
  name = "datahub"
  repository = ""
  # Dirty workaround to deal with an existing issue with the helm terraform provider
  # https://hub.com/aws-ia/terraform-aws-eks-blueprints/issues/825
  chart      = "datahub-0.2.154.tgz"
  namespace  = kubernetes_namespace.datahub_namespace.id
  timeout = 1000
  version = ""
  values = [
    file("${path.module}/datahub-values.yaml")
  ]

  depends_on = [
    helm_release.datahub_prerequisites_release
  ]
}

# resource "kubernetes_ingress_v1" "nuodata_ingress" {
#   wait_for_load_balancer = true
#   metadata {
#     name = "datahub-datahub-frontend"
#     annotations = {
#     }
#     namespace = "datahub"
#   }

#   spec {
#     ingress_class_name = "nginx"
#     rule {
#       http {
#         path {
#           path = "/"
#           backend {
#             service {
#               name = "datahub-datahub-frontend"
#               port {
#                 number = 9002
#               }
#             }
#           }
#         }
#       }
#     }

#     # tls {
#     #   secret_name = "tls-secret"
#     # }
#   }
#   depends_on = [
#     helm_release.datahub_release
#   ]
# }

# output "load_balancer_ip" {
#   value = kubernetes_ingress_v1.nuodata_ingress.status.0.load_balancer.0.ingress.0.hostname
# }

output "secret_val" {
  value = random_password.random_master_password.result
  sensitive = true
}

output "encoded_token" {
  value = base64encode(random_password.random_token.result)
  sensitive = true
}

output "decoded_token" {
  value = random_password.random_token.result
  sensitive = true
}

