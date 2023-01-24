data "aws_caller_identity" "current" {}
provider "kubernetes" {
  host                   = module.eks_blueprints.eks_cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks_blueprints.eks_cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.this.token
}

provider "helm" {
  kubernetes {
    host                   = module.eks_blueprints.eks_cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks_blueprints.eks_cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.this.token
  }
}

data "aws_eks_cluster_auth" "this" {
  name = module.eks_blueprints.eks_cluster_id
}

#---------------------------------------------------------------
# EKS Blueprints
#---------------------------------------------------------------

module "eks_blueprints" {
  source = "github.com/aws-ia/terraform-aws-eks-blueprints?ref=v4.18.1"

  # EKS CONTROL PLANE VARIABLES
  cluster_name    = local.cluster_name
  cluster_version = local.cluster_version

  # EKS Cluster VPC and Subnet mandatory config
  vpc_id             = data.terraform_remote_state.networking.outputs.vpc_id
  private_subnet_ids = data.terraform_remote_state.networking.outputs.service_subnet_ids

  # EKS MANAGED NODE GROUPS
  managed_node_groups = {
    mg = {
      node_group_name = "managed-on-demand"
      instance_types  = ["t3.small"]
      min_size        = 2
      subnet_ids      = data.terraform_remote_state.networking.outputs.service_subnet_ids
    }
  }
  # Adding 14 day retention period of cw losgs
  cloudwatch_log_group_retention_in_days = 14

  tags = local.tags
}

#---------------------------------------------------------------
# EKS Blueprints Addons
#---------------------------------------------------------------

module "eks_blueprints_kubernetes_addons" {
  source = "github.com/aws-ia/terraform-aws-eks-blueprints//modules/kubernetes-addons?ref=v4.18.1"

  eks_cluster_id = module.eks_blueprints.eks_cluster_id

  # Deploy Crossplane
  enable_crossplane = true

  crossplane_helm_config = local.crossplane_helm_config

  #---------------------------------------------------------
  # Crossplane AWS Provider deployment
  #   Creates ProviderConfig name as "aws-provider-config"
  #---------------------------------------------------------
  crossplane_aws_provider = local.crossplane_aws_provider

  #---------------------------------------------------------
  # Crossplane Kubernetes Provider deployment
  #   Creates ProviderConfig name as "kubernetes-provider-config"
  #---------------------------------------------------------
  crossplane_kubernetes_provider = local.crossplane_kubernetes_provider

  depends_on = [module.eks_blueprints.managed_node_groups]
}
