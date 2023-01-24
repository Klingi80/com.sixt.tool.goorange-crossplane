resource "aws_kms_key" "key" {
  description = "${local.cluster_name}-eks"

  tags = {
    Name = "${local.cluster_name}-eks"
  }
}

resource "aws_kms_alias" "alias" {
  name          = "alias/${local.cluster_name}-eks"
  target_key_id = aws_kms_key.key.id
}
