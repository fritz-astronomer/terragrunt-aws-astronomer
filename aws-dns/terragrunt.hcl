include "root" {
  path = find_in_parent_folders()
}


dependency aws-astro-ee {
  config_path = "../aws-astro-ee"
  mock_outputs = {
    route53_zone = "solutions.astronomer-sandbox.io"
    hostname = ""
  }
}

dependency app-astro-ee {
  config_path = "../app-astro-ee"
  mock_outputs = {
    dns_name = "asdf-xyz-1234-999a"
    service_zone_id = "XYZ"
  }
}

inputs = {
  region = "us-east-2"
  hostname = dependency.aws-astro-ee.outputs.hostname
  route53_zone = dependency.aws-astro-ee.outputs.route53_zone
  dns_name = dependency.app-astro-ee.outputs.dns_name
  service_zone_id = dependency.app-astro-ee.outputs.service_zone_id
}
