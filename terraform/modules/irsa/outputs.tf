output "role_name" {
  value = aws_iam_role.iam-role-for-service-account.name
}

output "service_account_name" {
  value = var.service_name
}
