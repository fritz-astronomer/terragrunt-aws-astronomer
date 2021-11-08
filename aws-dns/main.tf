terraform {
  required_providers {
    aws = ">= 3.63.0"
  }
  required_version = ">= 1.0.9"
}

provider "aws" {
  region = var.region
}

variable region {}
variable hostname {}
variable route53_zone {}
variable dns_name {}
variable service_zone_id {}

data aws_route53_zone zone {
  name = var.route53_zone
}

resource aws_route53_record dns_record_wildcard {
  zone_id = data.aws_route53_zone.zone.zone_id
  name    = "*.${var.hostname}"
  type    = "A"
  alias {
    evaluate_target_health = false
    name = var.dns_name
    zone_id = var.service_zone_id
  }
}


resource aws_route53_record dns_record {
  zone_id = data.aws_route53_zone.zone.zone_id
  name    = var.hostname
  type    = "A"
  alias {
    evaluate_target_health = false
    name = var.dns_name
    zone_id = var.service_zone_id
  }
}
