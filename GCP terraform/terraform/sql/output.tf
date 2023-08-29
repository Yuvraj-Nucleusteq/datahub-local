output "mysql_password" {
  value     = random_password.random_master_password.result
  sensitive = true
}
output "sql_url" {
  value = google_sql_user.user.host
}