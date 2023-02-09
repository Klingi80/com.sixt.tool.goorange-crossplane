module "irsa_aws_provider_admin" {
  source = "../../../modules/irsa"

  namespace        = "crossplane-system"
  oidc_provider    = data.terraform_remote_state.crossplane_ek_cluster.outputs.cluster_oidc_provider
  account_id       = "227837763243"
  service_name     = "aws-provider"
  environment_name = "dev"
}

resource "aws_iam_role_policy_attachment" "irsa_s3_full_access" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
    role       = module.irsa_aws_provider_admin.role_name
}

resource "aws_iam_role_policy_attachment" "irsa_iam_full_access" {
    policy_arn = "arn:aws:iam::aws:policy/IAMFullAccess"
    role       = module.irsa_aws_provider_admin.role_name
}