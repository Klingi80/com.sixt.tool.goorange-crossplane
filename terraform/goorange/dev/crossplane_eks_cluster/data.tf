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
      amazon_ssm_managed_instance_core = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
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
    }
  ]
  sixt_pullach_allocation_restricted = [
    "185.97.224.0/25",
    "185.97.224.128/26",
    "185.97.224.192/28",
    "185.97.224.208/30",
    "185.97.224.212/31",
    "185.97.224.214/32",
    "185.97.224.216/29",
    "185.97.224.224/27",
    "185.97.225.0/24",
    "185.97.226.0/23"
  ]

  # sixt offices excluding pullach
  sixt_public_cidr = [
    #"176.37.169.140/32",  # kyiv
    #"62.80.184.44/32",    # kyiv
    #"213.159.246.16/32",  # kyiv
    "52.208.230.210/32",  # goorange vpn
    "14.143.35.46/32",    # Sixt R&D (India), TATA
    "182.73.65.110/32",   # Sixt R&D (India), Airtel
    "14.140.250.170/32",  # Sixt R&D (India)
    "185.114.121.135/32", # cato fankfurt
    "209.206.26.130/32",  # cato zürich
    "185.114.122.114/32", # cato amsterdam
    "209.206.13.75/32",   # cato milano
    "209.206.8.10/32",    # cato paris
    "185.114.123.77/32",  # cato london
    "209.206.24.6/32",    # cato madrid
    "140.82.201.38/32",   # cato India
    "145.62.186.129/32",  # cato New York
    "45.62.181.10/32",    # cato Miami
    "45.62.177.196/32",   # cato Los Angeles
    "45.62.178.190/32",   # cato Chicago
    "185.114.121.45/32",  # cato Frankfurt
    "45.62.181.32/32"     # USA office
  ]
}
