provider "aws" {
  region = "eu-central-1"
  assume_role {
    role_arn = "arn:aws:iam::227837763243:role/OrganizationAccountAccessRole"
  }
}

terraform {
  required_version = "= 1.3.7"

  required_providers {
    aws = {
      version = "4.50.0"
    }
  }

  backend "s3" {
    bucket         = "sixt-terraform-state"
    key            = "goorange/dev/crossplane_ek_cluster/terraform.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "terraform_state_lock"
  }
}

data "aws_eks_cluster_auth" "eks" {
  name = module.eks.cluster_id
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.eks.token
}
