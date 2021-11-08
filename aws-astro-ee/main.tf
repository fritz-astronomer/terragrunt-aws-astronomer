terraform {
  required_providers {
    aws = ">= 3.63.0"
    random = ">= 3.1"
    eksctl = {
      source = "mumoshu/eksctl"
      version = "0.16.2"
    }
  }
  required_version = ">= 1.0.9"
}

provider "aws" {
  region = var.region
}

data aws_caller_identity current {}
data aws_vpc eks {
  depends_on = [eksctl_cluster.cluster]
  tags = {
    Name = "eksctl-${var.cluster_name}-cluster/VPC"
  }
}

data aws_subnet_ids eks {
  depends_on = [eksctl_cluster.cluster]
  vpc_id = data.aws_vpc.eks.id
}
data aws_route53_zone zone {
  name = var.route53_zone
}

data aws_eks_cluster eks {
  depends_on = [eksctl_cluster.cluster]
  name = var.cluster_name
}

variable region {
  type = string
}
variable cluster_config {
  type = string
}
variable cluster_name {
  type = string
}
variable kubernetes_version {
  type = string
  default = "1.20"
}
variable database_instance_size {
  type = string
  default = "db.t3.large"
}
variable hostname {
  type = string
}
variable postgres_version {
  type = string
  default = "13.1"
}
variable postgres_storage_gb {
  type = number
  default = 30
}
variable route53_zone {
  type = string
}
output db_connection {
  sensitive = true
  value = "postgres://${aws_db_instance.db.username}:${aws_db_instance.db.password}@${aws_db_instance.db.endpoint}"
}
output certificate_arn {
  value = aws_acm_certificate.wildcard.arn
}
output smtp_conn {
  sensitive = true
  value = "smtps://${aws_iam_access_key.email.id}:${aws_iam_access_key.email.ses_smtp_password_v4}@email-smtp.${var.region}.amazonaws.com?requireTLS=true"
}

# Variable passthru (reduce copypaste issues)
output cluster_name {
  value = var.cluster_name
}
output route53_zone {
  value = var.route53_zone
}
output hostname {
  value = var.hostname
}
output cluster_endpoint {
  depends_on = [
    eksctl_cluster.cluster
  ]
  value = data.aws_eks_cluster.eks.endpoint
}
output cluster_ca_certificate {
  depends_on = [
    eksctl_cluster.cluster
  ]
  sensitive = true
  value = data.aws_eks_cluster.eks.certificate_authority[0].data
}
output aws_user_arn {
  value = data.aws_caller_identity.current.arn
}
output vpc_id {
  value = data.aws_vpc.eks.id
}
output subnet_ids {
  value = data.aws_subnet_ids.eks.ids
}
output cidr_block {
  value = data.aws_vpc.eks.cidr_block
}