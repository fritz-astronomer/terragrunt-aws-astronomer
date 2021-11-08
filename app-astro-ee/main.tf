terraform {
  required_providers {
    kubernetes = ">= 2.5.1"
    helm = ">= 2.3.0"
    time = ">= 0.7.2"
    tls = ">= 3.1.0"
  }
  required_version = ">= 1.0.9"
}

provider "kubernetes" {
  host                   = var.cluster_endpoint
  cluster_ca_certificate = base64decode(var.cluster_ca_certificate)
  exec {
    api_version = "client.authentication.k8s.io/v1alpha1"
    args        = ["eks", "get-token", "--cluster-name", var.cluster_name]
    command     = "aws"
  }
}

provider helm {
  kubernetes {
    host  = var.cluster_endpoint
    cluster_ca_certificate = base64decode(var.cluster_ca_certificate)
    exec {
      api_version = "client.authentication.k8s.io/v1alpha1"
      args        = ["eks", "get-token", "--cluster-name", var.cluster_name]
      command     = "aws"
    }
  }
}

provider "aws" {
  region = var.region
}

data "kubernetes_service" "ingress_nginx" {
  depends_on = [helm_release.astronomer]

  metadata {
    name      = "astronomer-nginx"
    namespace = helm_release.astronomer.metadata[0].namespace
  }
}

data "aws_lb" "ingress_nginx" {
  depends_on = [helm_release.astronomer]
  name = regex(
    "(^\\w+-\\w+-\\w+-\\w+)",
    data.kubernetes_service.ingress_nginx.status[0].load_balancer[0].ingress[0].hostname
  )[0]
}

variable region {
  type = string
}
variable cluster_endpoint {
  type = string
}
variable cluster_ca_certificate {
  type = string
}
variable cluster_name {
  type = string
}
variable db_connection {
  type = string
}
variable hostname {
  type = string
}
variable chart_version {
  type = string
  default = "0.25.8"
}
variable chart_config {
  type = string
  description = <<EOF
  Chart configuration for the Astronomer Helm Chart.
  Note that a few variables (such as global.baseDomain, and astronomer.houston.config.email.reply) are set based off `hostname` and therefore are not required.
  Additional sensitive values can be set with `additional_sensitive_helm_values`

  EOF
}
variable additional_sensitive_helm_values {
  type = list(map(string))
}

output dns_name {
  value = data.aws_lb.ingress_nginx.dns_name
}

output service_zone_id {
  value = data.aws_lb.ingress_nginx.zone_id
}