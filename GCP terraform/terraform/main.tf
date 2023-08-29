terraform {
  required_providers {
    kubernetes = {
      version = "2.15.0"
      source  = "hashicorp/kubernetes"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "2.7.1"
    }
  }
}
provider "google" {
  credentials = file(var.gcp_credential)
  project = var.project_id
  region = var.region
}

data "google_client_config" "default" {}

resource "google_container_cluster" "primary" {
  name     = var.gke_cluster_name
  location = var.region
  remove_default_node_pool = true
  initial_node_count       = 3
}

resource "google_container_node_pool" "primary_preemptible_nodes" {
  name       = var.node_pools_name
  location   = var.region
  cluster    = google_container_cluster.primary.name
  node_count = 3

  node_config {
    machine_type = var.machine_type
    service_account = var.service_account_name
    disk_size_gb = 10
    oauth_scopes    = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}


module "sql" {
  source             = "./sql"
  database_version = var.database_version
  database_tier = var.database_tier
  database_name = var.database_name
  database_user_name = var.database_user_name
  region = var.region
  service_account_name = var.service_account_name
  project_id = var.project_id
}

module "nuodata_datahub" {
  source                   = "./nuodata_datahub"
  gke_cluster_name         = var.gke_cluster_name
  mysql_password           = module.sql.mysql_password
  sql_host                 = "${module.sql.sql_url}:3306"
  sql_username             = var.database_user_name
  sql_url                  = module.sql.sql_url
  region                   = var.region 

  depends_on = [ module.sql ]
}


