resource "kubernetes_secret" "astronomer_tls" {
  metadata {
    name = "astronomer-tls"
    namespace = "astronomer"
  }

  type = "kubernetes.io/tls"

  data = {
    "tls.crt" = tls_self_signed_cert.tls.cert_pem
    "tls.key" = tls_private_key.tls.private_key_pem
  }
  depends_on = [
    kubernetes_namespace.astronomer,
    tls_self_signed_cert.tls,
    tls_private_key.tls
  ]
}

resource "kubernetes_secret" "astronomer_bootstrap" {
  metadata {
    name = "astronomer-bootstrap"
    namespace = "astronomer"
  }
  type = "kubernetes.io/generic"

  data = {
    connection = var.db_connection
  }
  depends_on = [
    kubernetes_namespace.astronomer
  ]
}