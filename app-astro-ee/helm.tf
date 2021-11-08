resource helm_release astronomer {
  name       = "astronomer"
  repository = "https://helm.astronomer.io/"
  chart      = "astronomer"
  namespace = "astronomer"
  version    = var.chart_version
  timeout   = 900
  wait = true

  dynamic set_sensitive {
    for_each = var.additional_sensitive_helm_values
    content {
      name = set_sensitive.value["name"]
      value = set_sensitive.value["value"]
    }
  }

  set {
    name = "global.baseDomain"
    value = var.hostname
  }

  set {
    name  = "astronomer.houston.config.email.reply"
    value = "noreply@${var.hostname}"
  }

  values = [var.chart_config]

  depends_on = [
    kubernetes_namespace.astronomer,
    kubernetes_secret.astronomer_bootstrap,
    kubernetes_secret.astronomer_tls
  ]
}