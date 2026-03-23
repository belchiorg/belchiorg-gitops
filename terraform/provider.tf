terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.45"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
}

provider "hcloud" {
  token = var.hcloud_token
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

provider "kubernetes" {
  host                   = var.kubernetes_cluster_host
  cluster_ca_certificate = base64decode(trimspace(var.kubernetes_cluster_ca))
  client_certificate     = base64decode(trimspace(var.kubernetes_client_cert))
  client_key             = base64decode(trimspace(var.kubernetes_client_key))
}

provider "helm" {
  version = "~> 2.15"
  kubernetes {
    host                   = var.kubernetes_cluster_host
    cluster_ca_certificate = base64decode(trimspace(var.kubernetes_cluster_ca))
    client_certificate     = base64decode(trimspace(var.kubernetes_client_cert))
    client_key             = base64decode(trimspace(var.kubernetes_client_key))
  }
}