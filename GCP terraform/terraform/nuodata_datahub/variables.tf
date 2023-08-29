variable "mysql_password" {
  description = "The MySQL Password for Datahub"
  type        = string
}
variable "sql_host" {
  description = "The RDS writer instance hostname"
  type        = string
}
variable "sql_url" {
  description = "Complete jdbc url to connect to the RDS database"
  type        = string
}

variable "sql_username" {
  description = "The master username to connect to RDS"
  type        = string
}
variable "gke_cluster_name" {
  type = string
  description = "cluster name to deploy the software"
}
variable "region" {
  type = string
  description = "region in which the service is dedployed"
}


