resource "kubernetes_namespace_v1" "main" {
  for_each = toset(["asiayo"])

  metadata {
    name = each.value
  }
}