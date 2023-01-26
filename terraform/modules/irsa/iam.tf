data "aws_iam_policy_document" "assume-role-from-service-account" {
  statement {
    effect = "Allow"
    principals {
      identifiers = ["arn:aws:iam::${var.account_id}:oidc-provider/${var.oidc_provider}"]
      type        = "Federated"
    }
    actions = ["sts:AssumeRoleWithWebIdentity"]
    condition {
      test     = "StringLike"
      values   = ["system:serviceaccount:${var.namespace}:${var.service_name}-*"]
      variable = "${var.oidc_provider}:sub"
    }
    condition {
      test     = "StringLike"
      values   = ["sts.amazonaws.com"]
      variable = "${var.oidc_provider}:aud"
    }
  }
}

resource "aws_iam_role" "iam-role-for-service-account" {
  name               = "k8s-sa-${var.service_name}-admin-${var.environment_name}"  # Added admin word here temporarily. Will clean it up later
  assume_role_policy = data.aws_iam_policy_document.assume-role-from-service-account.json
}
