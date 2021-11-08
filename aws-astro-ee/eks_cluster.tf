resource aws_iam_role master_eks_role {
  name = "${var.cluster_name}_master_eks_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          "AWS" = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
      },
    ]
  })

  inline_policy {
    name = "eks_admin_access"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action   = ["eks:*"]
          Effect   = "Allow"
          Resource = "*"
        },
        {
          "Effect": "Allow",
          "Action": "iam:PassRole",
          "Resource": "*",
          "Condition": {
            "StringEquals": {
              "iam:PassedToService": "eks.amazonaws.com"
            }
          }
        }
      ]
    })
  }
}

resource eksctl_cluster cluster {
  name = var.cluster_name
  region = var.region
  spec = var.cluster_config
  version = var.kubernetes_version

  iam_identity_mapping {
    iamarn   = aws_iam_role.master_eks_role.arn
    username = aws_iam_role.master_eks_role.name
    groups   = ["system:masters"]
  }
}
