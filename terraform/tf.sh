#!/usr/bin/env bash
set -euo pipefail

export TF_VAR_hcloud_token="$(pass personal/hcloud-token)"
export TF_VAR_cloudflare_api_token="$(pass personal/cloudflare-api-token)"
export TF_VAR_kubernetes_cluster_ca="$(pass personal/k8s-cluster-ca)"
export TF_VAR_kubernetes_client_cert="$(pass personal/k8s-client-cert)"
export TF_VAR_kubernetes_client_key="$(pass personal/k8s-client-key)"
export TF_VAR_age_private_key="$(pass personal/age-private-key)"

terraform "$@"
