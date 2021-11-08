resource aws_ses_domain_identity email {
  domain = var.hostname
}

##### USE DKIM TO VERIFY THE EMAILS WE SEND ARE REAL (avoid spam??)
resource aws_ses_domain_dkim email {
  domain = aws_ses_domain_identity.email.domain
}

resource aws_route53_record email_amazonses_dkim_record {
  count   = 3
  zone_id = data.aws_route53_zone.zone.zone_id
  name    = "${element(aws_ses_domain_dkim.email.dkim_tokens, count.index)}._domainkey"
  type    = "CNAME"
  ttl     = "600"
  records = ["${element(aws_ses_domain_dkim.email.dkim_tokens, count.index)}.dkim.amazonses.com"]
}

#### ADD TXT RECORDS FOR SES TO VERIFY THAT WE OWN THE DOMAIN #####
resource aws_route53_record email_amazonses_verification_record {
  zone_id = data.aws_route53_zone.zone.zone_id
  name    = "_amazonses.${aws_ses_domain_identity.email.id}"
  type    = "TXT"
  ttl     = "600"
  records = [aws_ses_domain_identity.email.verification_token]
}

resource aws_ses_domain_identity_verification email_verification {
  domain = aws_ses_domain_identity.email.id
  depends_on = [aws_route53_record.email_amazonses_verification_record]
}

##### CREATE AN IAM USER WHICH LETS US USE SMTP
data aws_iam_policy_document email {
  statement {
    actions   = ["SES:SendEmail", "SES:SendRawEmail"]
    resources = [aws_ses_domain_identity.email.arn]

    principals {
      identifiers = ["*"]
      type        = "AWS"
    }
  }
}

resource aws_ses_identity_policy email {
  identity = aws_ses_domain_identity.email.arn
  name     = var.cluster_name
  policy   = data.aws_iam_policy_document.email.json
}

resource aws_iam_user email {
  name = "${var.cluster_name}_email_user"
}

resource aws_iam_access_key email {
  user = aws_iam_user.email.name
}

resource aws_iam_user_policy email {
  name = "SendEmail"
  user = aws_iam_user.email.name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action =  ["SES:SendEmail", "SES:SendRawEmail"]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}
