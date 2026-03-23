# 1. Criar o Namespace primeiro
resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }
}

# 2. Criar o Secret logo a seguir (Depende do Namespace, não do Helm)
resource "kubernetes_secret" "sops_age_key" {
  metadata {
    name      = "sops-age-key"
    namespace = kubernetes_namespace.argocd.metadata[0].name
  }

  data = {
    "key.txt" = base64encode(trimspace(var.age_private_key))
  }
}

resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = true
  version          = "7.7.0"

  values = [
    yamlencode({
      configs = {
        cm = {
          "kustomize.buildOptions" = "--enable-alpha-plugins --enable-exec"
        }
      }

      repoServer = {
        env = [
          { name = "XDG_CONFIG_HOME", value = "/home/argocd/.config" },
          { name = "SOPS_AGE_KEY_FILE", value = "/home/argocd/.config/sops/age/key.txt" }
        ]
        volumes = [
          { name = "sops-age-key", secret = { secretName = "sops-age-key" } },
          { name = "custom-tools", emptyDir = {} }
        ]
        volumeMounts = [
          { name = "sops-age-key", mountPath = "/home/argocd/.config/sops/age", readOnly = true },
          { name = "custom-tools", mountPath = "/usr/local/bin/ksops", subPath = "ksops" }
        ]
        initContainers = [
          {
            name    = "install-ksops"
            image   = "alpine:3.18"
            command = ["/bin/sh", "-c"]
            args    = [
              "apk add --no-cache curl tar && curl -L https://github.com/viaduct-ai/kustomize-sops/releases/download/v4.3.1/ksops_4.3.1_Linux_x86_64.tar.gz | tar -xzf - && mv ksops /custom-tools/ksops && chmod +x /custom-tools/ksops"
            ]
            volumeMounts = [
              { name = "custom-tools", mountPath = "/custom-tools" }
            ]
          }
        ]
      }
    })
  ]

  depends_on = [
    kubernetes_namespace.argocd,
    kubernetes_secret.sops_age_key
  ]
}
