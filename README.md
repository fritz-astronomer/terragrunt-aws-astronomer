# Instructions
```shell
terragrunt run-all apply
```
or - one at a time
```shell
cd aws-astro-ee && terragrunt apply
```

# Setup
This project utilizes: terraform, terragrunt, eksctl, helm. Please have all those downloaded.

Please fully understand the normal install instructions - as that's what this terraform project replicates:
https://www.astronomer.io/docs/enterprise/v0.25/install/aws/install-aws-standard

Please change the `input` blocks within each `terragrunt.hcl` file

# Why Terragrunt
The Astronomer Enterprise setup requires `aws` (eks) -> `kubernetes/helm` (inside eks) -> `aws` (get values from eks and apply elsewhere).

Terraform has a chicken/egg problem that has existed since at least 2015, especially regarding partial-applies
and resolution of dependencies in modules or provider instantiation. 
<https://github.com/hashicorp/terraform/issues/1178>
<https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1280#issuecomment-810533105>

The solution around this problem without Terragrunt (<https://terragrunt.gruntwork.io/>) is to keep sub-modules COMPLETELY separate, 
and you lose the ability to apply all your infrastructure at once. Terragrunt is a thin wrapper that re-allows this by creating a dependency graph
between modules.

# Astronomer AWS Cluster
- Uses `cluster.yaml` for eksctl  
- NOTE: `eksctl` should be replaced with the EKS module for a production setup
- NOTE: RDS should be managed and tuned for a production setup. Consider replacing with Aurora.
- Creates SES, RDS, ACM, Route53

# Astronomer App
- Uses `helm` with `values.yaml` 
- Uses a self-signed certificate for `astronomer-tls`
- NOTE: that we are setting `nginx.ingressAnnotations` `service.beta.kubernetes.io/aws-load-balancer-ssl-cert` with the ACM ARN
- Creates `astronomer-bootstrap` with RDS credentials
- Creates DNS entries in Route53

# AWS DNS
- Sets a `*.BASEDOMAIN` DNS record in a Route53 zone