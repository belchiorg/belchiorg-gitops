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

resource "kubernetes_manifest" "my_website_app" {
  manifest = {
    "apiVersion" = "argoproj.io/v1alpha1"
    "kind"       = "Application"
    "metadata" = {
      "name"      = "my-website"
      "namespace" = "argocd"
    }
    "spec" = {
      "project" = "default"
      "source" = {
        "repoURL"        = "https://github.com/belchiorg/belchiorg-gitops.git"
        "targetRevision" = "HEAD"
        "path"           = "apps/my-website"
      }
      "destination" = {
        "server"    = "https://kubernetes.default.svc"
        "namespace" = "default"
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