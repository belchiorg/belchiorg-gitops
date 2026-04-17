resource "kubernetes_manifest" "anytype_app" {
  manifest = {
    "apiVersion" = "argoproj.io/v1alpha1"
    "kind"       = "Application"
    "metadata" = {
      "name"      = "anytype"
      "namespace" = "argocd"
    }
    "spec" = {
      "project" = "default"
      "source" = {
        "repoURL"        = "https://github.com/belchiorg/belchiorg-gitops.git"
        "targetRevision" = "HEAD"
        "path"           = "apps/anytype"
      }
      "destination" = {
        "server"    = "https://kubernetes.default.svc"
        "namespace" = "anytype"
      }
      "syncPolicy" = {
        "automated" = {
          "prune"    = true
          "selfHeal" = true
        }
        "syncOptions" = [
          "CreateNamespace=true"
        ]
      }
    }
  }
}

resource "kubernetes_manifest" "portfolio_app" {
  manifest = {
    "apiVersion" = "argoproj.io/v1alpha1"
    "kind"       = "Application"
    "metadata" = {
      "name"      = "portfolio"
      "namespace" = "argocd"
    }
    "spec" = {
      "project" = "default"
      "source" = {
        "repoURL"        = "https://github.com/belchiorg/belchiorg-gitops.git"
        "targetRevision" = "HEAD"
        "path"           = "apps/portfolio"
      }
      "destination" = {
        "server"    = "https://kubernetes.default.svc"
        "namespace" = "portfolio"
      }
      "syncPolicy" = {
        "automated" = {
          "prune"    = true
          "selfHeal" = true
        }
        "syncOptions" = [
          "CreateNamespace=true"
        ]
      }
    }
  }
}