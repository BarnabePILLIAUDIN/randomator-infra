# Randomator Infra

## Overview

This is the repo with the infrastructure code for this [repo](https://github.com/BarnabePILLIAUDIN/Randomator)

## Helm chart

Prerequisites

- Helm 3.x installed and on your PATH.
- kubectl configured to point at the target Kubernetes cluster.
- (Optional) A values file to override defaults: values.yaml

Quick install (local chart)

1/ Create your values.local.yaml based on values.yaml with your custom settings.

```sh
cp helm/values.yaml helm/values.local.yaml
# edit helm/values.local.yaml to set your values
```

2/ Install the ingress controller if not already done:

```sh
./ingress-controller/install-ingress-controller.sh
```

3/ From the repo root (assumes chart is at ./charts/randomator):

```sh
cd helm
helm upgrade --install randomator-local \
  --values values.local.yaml \
  --namespace randomator \
  --create-namespace 
```
