resource "kubernetes_namespace" "astronomer" {
  metadata {
    name = "astronomer"
  }
}