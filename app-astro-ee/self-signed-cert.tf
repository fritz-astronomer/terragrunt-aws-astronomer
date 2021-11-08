resource tls_private_key tls {
  algorithm   = "ECDSA"
  ecdsa_curve = "P384"
}

resource tls_self_signed_cert tls {
  key_algorithm   = "ECDSA"
  private_key_pem = tls_private_key.tls.private_key_pem

  subject {
    common_name  = "*.${var.hostname}"
    organization = "Astronomer.io"
  }

  validity_period_hours = 31800 # 5 years

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}