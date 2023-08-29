variable "region" {
  type = string
  description = "GCP region"
}
variable "project_id" {
  type = string
  description = "GCP project id"
}
variable "gcp_credential" {
  type = string
  description = "Location of the service account of GCP"
}
variable "gke_cluster_name" {
  type = string 
  description = "Name of the GKE cluster"
}
variable "gke_zones" {
  type = list(string)
  description = "Zones for the cluster nodes"
}
variable "node_pools_name" {
  type = string
  description = "name for node pool"
}
variable "service_account_name" {
  type = string
  description = "GKE service account name"
}
variable "machine_type" {
  type = string
  description = "Type of machine configuration on which the cluster will run"
}
variable "database_version" {
  type = string
  description = "Sql version which will be used"
}
variable "database_tier" {
  type = string
  description = "Type of confirgurations used by database"
}
variable "database_name" {
  type = string
  description = "name of the database"
}
variable "database_user_name" {
  type = string
  description = "username of the database"
}
variable "environment" {
  type = string
  description = "environment in which the application is running"
}