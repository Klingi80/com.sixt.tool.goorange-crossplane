module "irsa_aws_provider_admin" {
  source = "../../../modules/irsa"

  namespace        = "crossplane-system"
  oidc_provider    = data.terraform_remote_state.crossplane_ek_cluster.outputs.cluster_oidc_provider
  account_id       = "227837763243"
  service_name     = "aws-provider"
  environment_name = "dev"
}

resource "aws_iam_role_policy_attachment" "irsa" {
    policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
    role       = module.irsa_aws_provider_admin.role_name
}