variable "account_id" {
  description = "The ID of the account in which the role needs to exist. Used to build an ARN"
}

variable "oidc_provider" {
  description = "The cluster's OIDC provider (basically the url without the schema https://)"
}

variable "service_name" {
  description = "The name of the service, the role is created for, e.g. com-sixt-service-ping"
}

variable "namespace" {
  description = "The namespace in which the service pods are running, necessary for the assume role"
}

variable "environment_name" {
  description = "The name of the environment: dev, stage, prod"
}
