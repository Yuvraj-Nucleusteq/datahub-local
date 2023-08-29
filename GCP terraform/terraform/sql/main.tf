resource "google_sql_database_instance" "mysql" {
  name = var.database_name
  region = var.region
  database_version = var.database_version
  settings {
    tier = var.database_tier
  }
  deletion_protection = "false"
}

resource "google_sql_database" "database" {
  name = "sql-database"
  instance = google_sql_database_instance.mysql.name
}

resource "google_project_iam_policy" "instance_policy" {
  project = var.project_id

  policy_data = jsonencode({
    bindings = [
      {
        role = "roles/cloudsql.editor",
        members = [
          "serviceAccount:${var.service_account_name}"
        ]
      }
    ]
  })
}

resource "random_password" "random_master_password" {
  length           = 16
  special          = true
  override_special = "_!%^"
}

resource "google_sql_user" "user" {
  name = var.database_user_name
  instance = google_sql_database.database.name
  password = random_password.random_master_password.result
}