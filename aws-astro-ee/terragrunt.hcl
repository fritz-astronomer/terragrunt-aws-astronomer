include "root" {
  path = find_in_parent_folders()
}

inputs = {
  cluster_name = "cortica"
  cluster_config = file("../cluster.yaml")
  hostname = "cortica.solutions.astronomer-sandbox.io"
  route53_zone = "solutions.astronomer-sandbox.io"
  region = "us-east-2"
  postgres_version = "13.3"
}