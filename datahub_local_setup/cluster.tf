# locals {
#   name   = "test"
#   region = "us-west-1"
# }

# data "aws_vpc" "nuodata_vpc" {
#   # tags = {
#   #   Name = "default"
#   # }
#   default = true
# }

# data "aws_subnets" "cluster_public_subnets" {
#   filter {
#     name   = "vpc-id"
#     values = [data.aws_vpc.nuodata_vpc.id]
#   }

#   tags = {
#     Tier = "public"
#   }
# }

# resource "aws_iam_role" "nuodata_eks_cluster_role" {
#   name        = "eks-cluster-role"
#   description = "Allows cluster to manage node groups & fargate nodes"

#   assume_role_policy = <<POLICY
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Effect": "Allow",
#       "Principal": {
#         "Service": "eks.amazonaws.com"
#       },
#       "Action": "sts:AssumeRole"
#     }
#   ]
# }
# POLICY
# }

# resource "aws_iam_role_policy_attachment" "nuodata_eks_cluster_policy" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
#   role       = aws_iam_role.nuodata_eks_cluster_role.name
# }

# # Create the EKS cluster
# resource "aws_eks_cluster" "nuodata_eks_cluster" {
#   name     = "test-cluster"
#   version  = "1.24"
#   role_arn = aws_iam_role.nuodata_eks_cluster_role.arn

#   vpc_config {
#     subnet_ids              = ["subnet-03e59e45d439fe999","subnet-091d590653e40d278"]
#     endpoint_private_access = false
#     endpoint_public_access  = true
#     public_access_cidrs     = ["0.0.0.0/0"]
#   }

#   depends_on = [
#     aws_iam_role.nuodata_eks_cluster_role
#   ]

#   # tags = merge(var.tags,
#   #   {
#   #     name = local.name
#   #   }
#   # )
# }


# # Create IAM role for the Fargate profile
# resource "aws_iam_role" "nuodata_eks_fargate_profile_role" {
#   name               = "fargate-profile-role"
#   assume_role_policy = <<POLICY
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Effect": "Allow",
#       "Principal": {
#         "Service": [
#           "eks.amazonaws.com",
#           "eks-fargate-pods.amazonaws.com"
#           ]
#       },
#       "Action": "sts:AssumeRole"
#     }
#   ]
# }
# POLICY
# }

# # Attach Fargat Pod Execution policy to the Fargate IAM role.
# resource "aws_iam_role_policy_attachment" "nuodata_eks_fargate_profile_policy" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"
#   role       = aws_iam_role.nuodata_eks_fargate_profile_role.name
# }

# # Create the Fargate profile to allow the pods in the namespaces declared
# # to be created in fargate mode.
# resource "aws_eks_fargate_profile" "nuodata_eks_kube_system_profile" {
#   cluster_name           = aws_eks_cluster.nuodata_eks_cluster.name
#   fargate_profile_name   = "kube-system-profile-${local.name}"
#   pod_execution_role_arn = aws_iam_role.nuodata_eks_fargate_profile_role.arn

#   # These subnets must have the following resource tag:
#   # kubernetes.io/cluster/<CLUSTER_NAME>.
#   subnet_ids = ["subnet-019180da82aadf6b7"]

#   # Enable fargate mode for all pods in kube-system namespace
#   selector {
#     namespace = "kube-system"
#   }

#   # Enable fargate mode for all pods in default namespace
#   selector {
#     namespace = "default"
#   }

#   selector {
#     namespace = "datahub*"
#   }

#   depends_on = [
#     aws_eks_cluster.nuodata_eks_cluster
#   ]
# }

# # Set the kubeconfig context to allow kubectl to interact with the EKS cluster
# # resource "null_resource" "update_kubeconfig" {
# #   provisioner "local-exec" {
# #     interpreter = ["/bin/bash", "-c"]
# #     command     = <<EOT
# #     aws eks update-kubeconfig --region us-west-1 --name test-cluster
# #     EOT
# #   }
# #   depends_on = [
# #     aws_eks_fargate_profile.nuodata_eks_kube_system_profile
# #   ]
# # }

# # # Patch the core dns pod created under kube-system namespace.
# # # This resource removes the EC2 annotation from the core dns pod
# # # to allow it to be scheduled in Fargate mode.
# # resource "null_resource" "patch_core_dns_pod" {
# #   provisioner "local-exec" {
# #     interpreter = ["/bin/bash", "-c"]
# #     command     = <<EOT
# #     kubectl patch deployment coredns -n kube-system --type json -p='[{"op": "remove", "path": "/spec/template/metadata/annotations/eks.amazonaws.com~1compute-type"}]'
# #     EOT
# #   }
# #   depends_on = [
# #     aws_eks_fargate_profile.nuodata_eks_kube_system_profile,
# #     #    null_resource.update_kubeconfig
# #   ]
# # }

# # resource "aws_s3_bucket" "b" {
# #   bucket = "nachi-test-bkt"
# # }

# # resource "aws_iam_role" "nuodata_governance_eks_fargate_profile_role" {
# #   name               = "test-governancetest-fargate-profile-role"
# #   assume_role_policy = <<POLICY
# # {
# #   "Version": "2012-10-17",
# #   "Statement": [
# #     {
# #       "Effect": "Allow",
# #       "Principal": {
# #         "Service": [
# #           "eks.amazonaws.com",
# #           "eks-fargate-pods.amazonaws.com"
# #           ]
# #       },
# #       "Action": "sts:AssumeRole"
# #     }
# #   ]
# # }
# # POLICY
# # }

# # # Attach Fargat Pod Execution policy to the Fargate IAM role.
# # resource "aws_iam_role_policy_attachment" "nuodata_governance_eks_fargate_profile_policy" {
# #   policy_arn = "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"
# #   role       = aws_iam_role.nuodata_governance_eks_fargate_profile_role.name
# # }

# # # Create the Fargate profile to allow the pods in the governance namespaces
# # # to be created in fargate mode.
# # resource "aws_eks_fargate_profile" "nuodata_governance_eks_namespace_profile" {
# #   cluster_name           = aws_eks_cluster.nuodata_eks_cluster.name
# #   fargate_profile_name   = "nuodata-governance-profile-test"
# #   pod_execution_role_arn = aws_iam_role.nuodata_governance_eks_fargate_profile_role.arn

# #   # These subnets must have the following resource tag:
# #   # kubernetes.io/cluster/<CLUSTER_NAME>.
# #   subnet_ids = ["subnet-019180da82aadf6b7"]

# #   # Enable fargate mode for all pods in namespaces matching datahub
# #   # Wild cards allows profile to run all pods in namespaces starting with datahub
# #   selector {
# #     namespace = "datahub*"
# #   }

# #   depends_on = [
# #     aws_eks_cluster.nuodata_eks_cluster
# #   ]
# # }