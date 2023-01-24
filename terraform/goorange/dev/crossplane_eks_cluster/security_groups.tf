resource "aws_security_group_rule" "cluster_api_alb_webhook_ingress" {
  for_each = module.eks.eks_managed_node_groups

  type                     = "ingress"
  from_port                = 9443
  to_port                  = 9443
  protocol                 = "tcp"
  source_security_group_id = module.eks.cluster_security_group_id
  security_group_id        = module.eks.node_security_group_id
  description              = "Cluster API to ALB Webhooks"
}
