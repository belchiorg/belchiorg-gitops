# Bitnami Sealed Secrets controller
# Encrypts Kubernetes Secrets so they can be stored safely in Git.
# Only the controller in the cluster can decrypt them.
# See: https://github.com/bitnami-labs/sealed-secrets

resource "kubernetes_namespace" "sealed_secrets" {
  metadata {
    name = "sealed-secrets"
  }
}

resource "helm_release" "sealed_secrets" {
  name             = "sealed-secrets"
  repository       = "https://bitnami-labs.github.io/sealed-secrets"
  chart            = "sealed-secrets"
  namespace        = kubernetes_namespace.sealed_secrets.metadata[0].name
  create_namespace = false
  version          = "2.18.4"

  depends_on = [kubernetes_namespace.sealed_secrets]
}
