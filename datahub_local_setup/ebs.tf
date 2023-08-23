# data "tls_certificate" "eks" {
#   url = "https://oidc.eks.us-west-1.amazonaws.com/id/329259700E17F2996D694D7A96049A5F"
# }

# resource "aws_iam_openid_connect_provider" "eks" {
#   client_id_list  = ["sts.amazonaws.com"]
#   thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
#   url             = "https://oidc.eks.us-west-1.amazonaws.com/id/329259700E17F2996D694D7A96049A5F"
# }

# data "aws_iam_policy_document" "ebs_csi_controller_trust_policy" {
#   statement {
#     actions = ["sts:AssumeRoleWithWebIdentity"]
#     effect  = "Allow"

#     condition {
#       test     = "StringEquals"
#       variable = "${replace("https://oidc.eks.us-west-1.amazonaws.com/id/329259700E17F2996D694D7A96049A5F", "https://", "")}:sub"
#       values   = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
#     }

#     principals {
#       identifiers = [aws_iam_openid_connect_provider.eks.arn]
#       type        = "Federated"
#     }
#   }
# }

# resource "aws_iam_role" "ebs_csi_controller_role" {
#   assume_role_policy = data.aws_iam_policy_document.ebs_csi_controller_trust_policy.json
#   name               = "ebs-csi-controller"
# #   tags               = var.tags
# }

# resource "aws_iam_policy" "ebs_csi_controller_policy" {
#   policy = file("${path.module}/EbsCsiController.json")
#   name   = "EBS-CSI-Policy"
# #   tags   = var.tags
# }

# resource "aws_iam_role_policy_attachment" "ebs_csi_controller_attach" {
#   role       = aws_iam_role.ebs_csi_controller_role.name
#   policy_arn = aws_iam_policy.ebs_csi_controller_policy.arn
# }

# # resource "aws_eks_addon" "example" {
# #   cluster_name      = "test-cluster"
# #   addon_name        = "aws-ebs-csi-driver"
# # #   addon_version     = "v1.8.7-eksbuild.3" #e.g., previous version v1.8.7-eksbuild.2 and the new version is v1.8.7-eksbuild.3
# # #   resolve_conflicts = "PRESERVE"
# #   service_account_role_arn = aws_iam_role.ebs_csi_controller_role.arn
# # }

# # # resource "kubernetes_service_account" "driver-sa" {
# # #     metadata {
# # #         name = "ebs-csi-controller"
# # #         namespace = "kube-system"
# # #         annotations = {
# # #             "eks.amazonaws.com/role-arn" = aws_iam_role.ebs_csi_controller_role.arn
# # #         }
# # #     }
# # #     # automount_service_account_token = true

# # # }

# resource "helm_release" "ebs_csi_driver" {
#   depends_on = [aws_iam_role.ebs_csi_controller_role ]
#   name       = "ebs-csi-driver-release"

#   repository = "https://kubernetes-sigs.github.io/aws-ebs-csi-driver"
#   chart      = "aws-ebs-csi-driver"
#   # version    = # leave blank to use the latest

#   namespace = "kube-system"

#   set {
#     name = "image.repository"
#     value = "602401143452.dkr.ecr.us-west-1.amazonaws.com/eks/aws-ebs-csi-driver" # Changes based on Region - This is for us-east-1 Additional Reference: https://docs.aws.amazon.com/eks/latest/userguide/add-ons-images.html
#   }

#   set {
#     name  = "controller.serviceAccount.create"
#     value = "true"
#   }

#   set {
#     name  = "controller.serviceAccount.name"
#     value = "ebs-csi-controller-sa"
#   }

#   set {
#     name  = "controller.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
#     value = "${aws_iam_role.ebs_csi_controller_role.arn}"
#   }
# }

# # # resource "helm_release" "ebs_csi_driver_release" {
# # #   name = "ebs-csi-driver-release"
# # #   repository = "https://kubernetes-sigs.github.io/aws-ebs-csi-driver"
# # #   chart      = "aws-ebs-csi-driver"
# # #   namespace  = "kube-system"

# # #     set {
# # #         name = "controller.region"
# # #         value = "us-west-1"
# # #     }
# # #     set {
# # #         name = "controller.serviceAccount.create"
# # #         value = false
# # #     }
# # #   set {
# # #     name = "controller.serviceAccount.name"
# # #     value = "ebs-csi-controller"
# # #   }

# # # #   set {
# # # #     name = "controller.serviceAccount.annotations"
# # # #     value = "{\"eks.amazonaws.com/role-arn\":\"${aws_iam_role.ebs_csi_controller_role.arn}\""
# # # #   }

# # # #   set {
# # # #     name = "controller.serviceAccount.annotations[0].value"
# # # #     value = aws_iam_role.ebs_csi_controller_role.arn
# # # #   }

# # #   depends_on = [
# # #     kubernetes_service_account.driver-sa,
# # #     aws_iam_role_policy_attachment.ebs_csi_controller_attach,
# # #    aws_eks_cluster.nuodata_eks_cluster
# # #   ]
# # # }

# resource "kubernetes_secret" "mysql_password" {
#   metadata {
#     name = "mysql-secrets"
#     namespace = "datahub-new"
#   }

#   data = {
#     "mysql-root-password"="datahub"
#   }

# #   depends_on = [
# #     kubernetes_namespace.datahub_namespace
# #   ]
# }

# resource "helm_release" "datahub_prerequisites_release" {
#   name = "prerequisites"
#   repository = "https://helm.datahubproject.io/"
#   chart      = "datahub-prerequisites"
#   namespace  = "datahub"
#   timeout = 300

#   values = [
#     file("${path.module}/prerequisites-values.yaml")
#   ]

# #   depends_on = [
# #     kubernetes_secret.datahub_users_secret

# #   ]
# }