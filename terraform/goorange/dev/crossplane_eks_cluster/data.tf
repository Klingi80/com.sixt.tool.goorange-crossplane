data "terraform_remote_state" "networking" {
  backend = "s3"

  config = {
    bucket = "sixt-terraform-state"
    key    = "goorange/dev/networking/terraform.tfstate"
    region = "eu-west-1"
  }
}

locals {
  account_id      = 227837763243
  cluster_version = "1.24"
  cluster_name    = "crossplane"

  node_security_group_additional_rules = {
    ingress_self_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }
    egress_all = {
      description      = "Node all egress"
      protocol         = "-1"
      from_port        = 0
      to_port          = 0
      type             = "egress"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  }

  worker_groups_defaults = {
    launch_template_version = "$Latest"
    create_launch_template  = true
    iam_role_additional_policies = {
      additional = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    }
  }

  worker_groups = {
    crossplane = {
      min_size       = 2
      max_size       = 2
      desired_size   = 2
      instance_types = ["t3.medium"]
      disk_size      = 20
      labels         = { public = false }
      subnet_ids     = data.terraform_remote_state.networking.outputs.service_subnet_ids
    }
  }

  roles_mapping = [
    {
      rolearn  = "arn:aws:iam::${local.account_id}:role/OrganizationAccountAccessRole"
      username = "admin:{{SessionName}}"
      groups   = ["system:masters"]
    },
  ]
}
