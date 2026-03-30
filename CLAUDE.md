# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

GitOps repository managing a single-node k3s cluster on Hetzner Cloud. ArgoCD continuously deploys from this repo. Two apps are managed: `anytype` (self-hosted sync network) and `my-website`.

## Key Workflows

### Applying changes
Never `kubectl apply` directly. Commit and push — ArgoCD will sync automatically. To force an immediate sync:
```bash
argocd app sync <app-name>
```

### Secrets
Secrets are managed with SOPS + AGE. The AGE private key is available via:
```bash
pass personal/age-private-key
```

**To edit an encrypted secret:**
```bash
SOPS_AGE_KEY=$(pass personal/age-private-key) sops apps/anytype/secret.enc.yaml
```

**To encrypt a new `secret.yaml`:**
```bash
SOPS_AGE_KEY=$(pass personal/age-private-key) sops -e secret.yaml > secret.enc.yaml
```

`secret.yaml` files are gitignored — only `secret.enc.yaml` is committed. The `.sops.yaml` at the repo root defines the AGE public key for all `*secret.yaml` files.

### Checking the cluster
```bash
export KUBECONFIG=$HOME/.kube/belchior-k3s.yaml
k get pods -A
k logs -n anytype deploy/coordinator
```

### Terraform
All infra changes go through Terraform. Use the wrapper script that loads credentials from `pass`:
```bash
cd terraform
./tf.sh plan
./tf.sh apply
```

## Architecture

### GitOps Flow
```
Git push → ArgoCD detects change → kustomize build (with ksops plugin) → kubectl apply
```

ArgoCD uses the [ksops](https://github.com/viaduct-ai/kustomize-sops) plugin to transparently decrypt SOPS secrets during `kustomize build`. The AGE private key is injected into the ArgoCD repo-server via a k8s Secret (`sops-age-key` in the `argocd` namespace).

### Secret Generator Pattern
Each app has a `secret-generator.yaml` (ksops kind) that references `secret.enc.yaml`. This is listed under `generators:` in `kustomization.yaml`, not `resources:`.

### Anytype Network
The anytype app runs 4 any-sync services that must share a consistent network configuration:
- **coordinator** (port 33010/33020) — space coordination
- **node** (33011/33021) — tree sync
- **filenode** (33012/33022) — file storage via MinIO
- **consensusnode** (33013/33023) — consensus log

All 4 services plus filenode/node's internal connections are configured via `any-sync-*.yml` keys in `anytype-configs` Secret. The `configmap-client.yaml` holds the public network config to upload to the Anytype desktop/mobile app.

**Important:** The `networkId` and `peerId` values in `configmap-client.yaml` must match what's in the secret configs. If the network is regenerated (e.g. via `make generate` in any-sync-dockercompose), all configs and the client ConfigMap must be updated together.

Services use `hostPort` for external access (no LoadBalancer/NodePort needed on single-node k3s). Anytype ports 33010–33023 are opened in the Hetzner firewall and the `anytype` DNS record bypasses Cloudflare proxy (raw TCP/UDP required).

### Infrastructure (Terraform)
- **Hetzner Cloud:** cpx32 ARM server in `hel1`
- **DNS:** Cloudflare — root proxied, `anytype` subdomain unproxied
- **Firewall:** SSH + k8s API restricted to Feedzai VPN (`195.23.0.0/16`); Anytype ports open to all
- **Storage:** `local-path` (k3s default) — all PVCs are node-local
