# belchiorg-gitops
Testing running a k3s cluster on a hetzner server

## Sealed Secrets (Bitnami)

The cluster runs [Bitnami Sealed Secrets](https://github.com/bitnami-labs/sealed-secrets), installed via Terraform in the `sealed-secrets` namespace. Secrets are encrypted so they can be stored in Git; only the controller in the cluster can decrypt them.

### Usage

1. **Install `kubeseal`** (once, on your machine):
   ```bash
   # macOS
   brew install kubeseal
   # Or download from: https://github.com/bitnami-labs/sealed-secrets/releases
   ```

2. **Create a Secret locally** (never commit this file):
   ```yaml
   # my-secret.yaml
   apiVersion: v1
   kind: Secret
   metadata:
     name: my-secret
     namespace: default
   type: Opaque
   stringData:
     PASSWORD: "sensitive-value"
   ```

3. **Seal it** (requires access to the cluster so `kubeseal` can fetch the controller’s public key):
   ```bash
   kubeseal --format yaml < my-secret.yaml > sealed-my-secret.yaml
   ```

4. **Commit and push** `sealed-my-secret.yaml`. Add it to your Kustomization or Argo CD app; the controller will create the real Secret in the cluster.
