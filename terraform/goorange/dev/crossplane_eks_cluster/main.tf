module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = local.cluster_name
  cluster_version = local.cluster_version
  version         = "v19.5.1"

  enable_irsa                     = true
  cluster_endpoint_private_access = true

  vpc_id = data.terraform_remote_state.networking.outputs.vpc_id

  cluster_enabled_log_types = [
    "audit",
    "authenticator"
  ]

  subnet_ids = concat(
    data.terraform_remote_state.networking.outputs.service_subnet_ids,
    data.terraform_remote_state.networking.outputs.public_subnet_ids,
    data.terraform_remote_state.networking.outputs.dmz_subnet_ids,
  )

  cloudwatch_log_group_retention_in_days = 14

  cluster_encryption_config = {
      provider_key_arn = aws_kms_key.key.arn
      resources        = ["secrets"]
    }

  node_security_group_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = null
  }

  manage_aws_auth_configmap = true
  aws_auth_roles            = local.roles_mapping

  node_security_group_additional_rules = local.node_security_group_additional_rules

  eks_managed_node_group_defaults = local.worker_groups_defaults
  eks_managed_node_groups         = local.worker_groups
}
