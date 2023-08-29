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
variable "region" {
  type = string
  description = "GCP region"
}
variable "project_id" {
  type = string
  description = "project name"
}
variable "service_account_name" {
  type = string
  description = "owner of the account"
}