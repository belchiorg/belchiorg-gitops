resource "kubernetes_namespace" "traefik" {
  metadata {
    name = "traefik"
  }
}

resource "helm_release" "traefik" {
  name             = "traefik"
  repository       = "https://traefik.github.io/charts"
  chart            = "traefik"
  namespace        = kubernetes_namespace.traefik.metadata[0].name
  create_namespace = false
  version          = "28.3.0"

  set {
    name  = "ports.web.hostPort"
    value = "80"
  }

  set {
    name  = "ports.websecure.hostPort"
    value = "443"
  }

  set {
    name  = "service.type"
    value = "ClusterIP"
  }

  depends_on = [kubernetes_namespace.traefik]
}
