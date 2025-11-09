# Randomator Infra

## Overview

This is the repo with the infrastructure code for this [repo](https://github.com/BarnabePILLIAUDIN/Randomator)

# randomator-infra — repository overview

This repository contains infrastructure and platform configuration for the Randomator project. It groups Kubernetes manifests, Helm charts, Terraform modules, and helper scripts for installing and configuring components in the target clusters and cloud provider.

This README documents the contents of the repository, explains the purpose of each folder, and lists how to install or operate each component. Where a folder contains an `install.sh`, that script is intended to contain everything needed to install the component. If there are prerequisite scripts (commonly with `.local` suffix like `create-preriquisties.sh.local` or `init-tofu.sh.local`), run them first as noted below.

## Quick start

1. Inspect each component folder to understand side effects and required credentials.
2. For components that provide an `install.sh`, run it from the folder. If there is a `*-prerequisites*.sh` or `*.local` prereq script, run that first as documented below.

Example (run from repository root):

```zsh
# example: run argocd install (see per-folder notes if prereqs exist)
cd argocd
# if there is a prereq script, run it first (see folder docs below)
./install.sh
```

Notes:

- Files with `.local` in the name are typically local overrides or helper scripts and may require editing for your environment (secrets, provider credentials, etc.).
- Always review scripts before running them, especially if they create cloud resources or modify cluster state.

## Folder reference

This section lists each top-level folder in the repository and describes purpose, important files, and how to install/use the component.

### `argocd/`

Purpose: Argo CD application and project definitions, plus helper install scripts.

Key files:

- `install.sh` — Primary installation script for Argo CD and related resources. This script is intended to contain everything needed to install the Argo CD component and applications defined here.
- `create-preriquisties.sh.local` — Local prerequisites script. Run this first if present; it usually contains environment-specific setup steps (namespaces, CRDs, secrets, or bootstrap steps) required before running `install.sh`.
- `prod-app.yaml`, `staging-app.yaml`, `randomator-project.yaml` — Argo CD Application and Project manifests used to bootstrap deployment of apps/projects.
- `values.yaml` — Optional configuration values used by the install process or templates.

Install notes:

1. If `create-preriquisties.sh.local` exists and is applicable to your environment, run it first:

```zsh
cd argocd
./create-preriquisties.sh.local
```

2. Run the main installer:

```zsh
cd argocd
./install.sh
```

`install.sh` is intended to be self-contained for installation. Review it and ensure you have the required cluster credentials and permissions.

### `cert-manager/`

Purpose: Install and configure Cert-Manager and an issuer (Let's Encrypt) for TLS certificate management in Kubernetes.

Key files:

- `install.sh` — Installs Cert-Manager and configures resources needed by the cluster. This script is intended to contain everything required to install Cert-Manager.
- `lets-encrypt-issuer.yaml` — Example Issuer/ClusterIssuer manifest for Let's Encrypt.

Install notes:

```zsh
cd cert-manager
./install.sh
```

Ensure you have cluster admin permissions and that the cluster can meet ACME requirements (ingress reachable on HTTP/HTTPS) if using Let's Encrypt.

### `crossplane/`

Purpose: Crossplane provider configs and examples for provisioning cloud resources (DNS example provided).

Key files:

- `install.sh` — Installs Crossplane and registers providers (intended to be self-contained).
- `provider-config.yaml` — Provider configuration for Crossplane (credentials reference, etc.).
- `dns-record-example.yaml` — Example Crossplane resource to create DNS records using a provider.
- `scaleway-exemple-auth.yaml`, `scaleway-provider.yaml`, `scaleway.yaml.local` — Examples and a local override file for using Scaleway provider.

Install notes:

```zsh
cd crossplane
./install.sh
```

Review `provider-config.yaml` and any `*.local` files to inject credentials or change provider settings before installing.

### `helm/`

Purpose: The Helm chart for the application(s), plus helper scripts for secret creation.

Key files and folders:

- `Chart.yaml` — Helm chart metadata.
- `values.yaml`, `values.staging.yaml`, `values.prod.yaml`, `values.yaml.local` — Chart values for different environments and a local override.
- `create-secret.sh`, `create-secret.sh.local` — Scripts to create Kubernetes secrets used by the chart. The `.local` script is likely to contain environment-specific secret generation (edit values or locations as needed).
- `templates/` — Helm templates including `deployments.yaml`, `ingresses.yaml`, `secrets.yaml`, and `services.yaml`.
- `docker-secret.yaml.local` — Local Docker registry secret example.

Install notes (Helm):

1. Create any needed secrets using provided scripts (if present). If there is a `.local` create-secret script, prefer that and edit it to fit your environment.

```zsh
cd helm
./create-secret.sh
# or run the local variant if present and configured
./create-secret.sh.local
```

2. Install or upgrade the Helm chart using `helm` (example):

```zsh
# example; change release name and namespace as needed
helm upgrade --install randomator ./helm -f helm/values.yaml --namespace randomator --create-namespace
```

Review `values.*.yaml` to match your environment.

### `ingress-nginx-controller/`

Purpose: Scripts and configs to install the NGINX Ingress Controller.

Key files:

- `install.sh` — Script to install the ingress controller. This script should contain the needed commands to deploy NGINX Ingress Controller into the cluster.

Install notes:

```zsh
cd ingress-nginx-controller
./install.sh
```

Verify the cluster allows creation of LoadBalancer services or configure a nodePort/hostNetwork approach depending on your environment.

### `terraform/`

Purpose: Terraform code for provisioning cloud resources (Azure example present) and reusable modules.

Structure overview:

- `terraform/azure/` — Main Terraform workspace for Azure. Contains `main.tf`, `provider.tf`, `vars.tf`, `outputs.tf`, `terraform.tfvars` and an example `terraform.tfvars.example`.
- `terraform/.terraform/` and `.terraform.lock.hcl` — Local terraform provider plugin cache and lockfile.
- `terraform/modules/` — Reusable Terraform modules including `aks/`, `network/`, and `resource-group/`.

Key files and notes:

- `init-tofu.sh.local` (under `terraform/azure/`) — A local helper script (probably to initialize Terraform with OpenTofu or a specific provider); run if it is required by your setup.
- `terraform.tfvars` — Contains variable values for this environment — sensitive or environment-specific values may be present; treat accordingly.

Usage notes:

1. Review and populate `terraform/azure/terraform.tfvars` (or create a new `terraform.tfvars` based on the example).
2. If there is an `init-tofu.sh.local` script that your environment expects, run it first to initialize providers:

```zsh
cd terraform/azure
# if required for your setup
./init-tofu.sh.local
# then run terraform init/apply as normal
terraform init
terraform apply -var-file=terraform.tfvars
```

3. The modules are in `terraform/modules/` (AKS, network, resource-group). Use them from the `main.tf` in `terraform/azure/`.

Caution: Terraform can create/modify/delete cloud resources. Ensure you understand the changes before applying and have the correct provider credentials configured.

### `.github/` (GitHub Actions workflows)

Purpose: Continuous Integration / Continuous Deployment workflows for the repository.

Key files:

- `workflows/deployment.yaml` — Workflow to build/deploy the infra (likely runs on push or PR). Review it to understand the CI steps.
- `workflows/destroy.yaml` — Workflow to tear down resources (dangerous if misused; usually requires extra safeguards).
- `workflows/publish-helm-pages.yaml` — Workflow to publish Helm pages or chart artifacts.

Notes:

- CI workflows may need secrets configured in the GitHub repository (cloud credentials, kubeconfigs, Helm repo credentials, etc.). Do not commit secrets to the repo — use GitHub repository secrets.

## Local / `.local` files

Files ending in `.local` are frequently used as environment-specific helpers or overrides. They may contain sample credentials, local initialization commands, or examples that you should edit before using in a non-local environment. Treat them as templates.

Examples in this repository:

- `argocd/create-preriquisties.sh.local` — run before `argocd/install.sh` if your target environment needs the prerequisite steps.
- `helm/create-secret.sh.local`, `helm/docker-secret.yaml.local` — local secret creation helpers; edit with correct credentials.
- `crossplane/scaleway.yaml.local`, `terraform/azure/init-tofu.sh.local` — provider-specific local helpers.

## Security and secrets

- Never commit real secrets to source control.
- Use Kubernetes Secrets, Vault, or cloud provider secret stores for production secrets.
- For CI, add credentials as repository secrets and reference them in workflows.

## Troubleshooting & tips

- Always review scripts before executing them.
- Run install scripts in a test cluster or isolated environment when possible.
- For Kubernetes installs, ensure you are targeting the intended `kubectl` context and namespace.
- For Terraform, run `terraform plan` and review the plan before `terraform apply`.

## Recommended checks before installing

- Confirm cloud provider credentials are set in environment variables or in provider config files.
- Check `values*.yaml` and `terraform.tfvars` for placeholders.
- Verify the presence and content of `.local` helper files and adjust them to your environment.

## Contribution

If you add or change scripts or manifests, please:

1. Add documentation (update this README or a relevant folder README).
2. Test in a non-production cluster.
3. Use CI workflows to validate changes where possible.

## Files added / edited by this task

- `README.md` — Root README updated to document repository structure and install guidance.

---

If you'd like, I can also:

- Convert this into `README.md` plus per-folder `README.md` files to keep each folder self-describing.
- Generate quick `helm` and `terraform` check scripts to validate environment readiness.

Tell me if you'd like the `README.md` content adjusted (more/less detail, add a diagram, or add exact command examples for each script).
