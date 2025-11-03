curl -sL "https://cli.upbound.io" | sh
sudo mv up /usr/local/bin/
up uxp install

helm repo add crossplane-stable https://charts.crossplane.io/stable
helm repo update
helm upgrade --install crossplane \
  --namespace crossplane-system \
  --create-namespace crossplane-stable/crossplane \
  --create-namespace --atomic