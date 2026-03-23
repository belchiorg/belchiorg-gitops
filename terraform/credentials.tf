resource "kubernetes_namespace" "credentials" {
  metadata {
    name = "credentials"
  }
}

resource "kubernetes_secret" "infra_credentials" {
  metadata {
    name      = "infra-credentials"
    namespace = kubernetes_namespace.credentials.metadata[0].name
  }

  data = {
    hcloud_token         = var.hcloud_token
    cloudflare_api_token = var.cloudflare_api_token
    cloudflare_zone_id   = var.cloudflare_zone_id
  }

  depends_on = [kubernetes_namespace.credentials]
}
