include "root" {
  path = find_in_parent_folders()
}

dependency aws-astro-ee {
  config_path = "../aws-astro-ee"

  mock_outputs = {
    cluster_name = ""
    certificate_arn = ""
    cluster_ca_certificate = ""
    cluster_endpoint = ""
    hostname = ""
    route53_zone = ""
    db_connection = ""
    smtp_conn = ""
  }
}

inputs = {
  source = "./app-astro-ee"
  chart_config = file("../values.yaml")
  additional_sensitive_helm_values = [
    {
      name  = "nginx.ingressAnnotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-ssl-cert"
      value = dependency.aws-astro-ee.outputs.certificate_arn
    }, {
      name  = "astronomer.houston.config.email.smtpUrl"
      value = dependency.aws-astro-ee.outputs.smtp_conn
    }
  ]

  region = "us-east-2"

  cluster_name = dependency.aws-astro-ee.outputs.cluster_name
  certificate_arn = dependency.aws-astro-ee.outputs.certificate_arn
  cluster_ca_certificate = dependency.aws-astro-ee.outputs.cluster_ca_certificate
  cluster_endpoint = dependency.aws-astro-ee.outputs.cluster_endpoint
  hostname = dependency.aws-astro-ee.outputs.hostname
  route53_zone = dependency.aws-astro-ee.outputs.route53_zone
  db_connection = dependency.aws-astro-ee.outputs.db_connection
  smtp_conn = dependency.aws-astro-ee.outputs.smtp_conn
}
