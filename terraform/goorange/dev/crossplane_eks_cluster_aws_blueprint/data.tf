locals {
  name   = "crossplane-cluster"

  cluster_version = "1.24"
  cluster_name    = local.name

  crossplane_helm_config = {
    #  name       = "crossplane"
    #  chart      = "crossplane"
    #  repository = "https://charts.crossplane.io/stable/"
    version = "1.10.1"
    #  namespace  = "crossplane-system"
    #  values = [templatefile("${path.module}/values.yaml", {
    #    operating-system = "linux"
    #  })]
  }

  # NOTE: Crossplane requires Admin like permissions to create and update resources similar to Terraform deploy role.
  # This example config uses AdministratorAccess for demo purpose only, but you should select a policy with the minimum permissions required to provision your resources
  crossplane_aws_provider = {
    enable                   = true
    provider_aws_version     = "v0.34.0"
    additional_irsa_policies = ["arn:aws:iam::aws:policy/AmazonS3FullAccess", "arn:aws:iam::aws:policy/IAMFullAccess"]
    # name                     = "aws-provider"
    # service_account          = "aws-provider"
    # provider_config          = "default"
    # controller_config        = "aws-controller-config"
  }

  crossplane_kubernetes_provider = {
    enable                      = true
    provider_kubernetes_version = "v0.5.0"
    #  name                        = "kubernetes-provider"
    #  service_account             = "kubernetes-provider"
    #  provider_config             = "default"
    #  controller_config           = "kubernetes-controller-config"
    #  cluster_role                = "cluster-admin"
  }

  tags = {
    Blueprint  = local.name
    GithubRepo = "github.com/awslabs/crossplane-on-eks"
  }
}

data "terraform_remote_state" "networking" {
  backend = "s3"

  config = {
    bucket = "sixt-terraform-state"
    key    = "goorange/dev/networking/terraform.tfstate"
    region = "eu-west-1"
  }
}