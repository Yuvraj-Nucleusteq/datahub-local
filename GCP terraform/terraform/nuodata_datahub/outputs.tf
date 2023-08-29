output "login_password" {
  value     = random_password.random_user_secret.result
  sensitive = true
}

output "auth_key" {
  value     = random_password.random_auth_key.result
  sensitive = true
}

