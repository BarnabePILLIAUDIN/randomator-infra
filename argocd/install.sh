helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
helm upgrade --install argocd argo/argo-cd \
  --values values.yaml \
  --namespace argocd \
  --create-namespace

# Wait for agrgocd to be ready and create a port forward might not work locally due to ssl
kubectl -n argocd wait --for=condition=available --timeout=120s deployment/argocd-server >/dev/null 2>&1 || {
  echo "Warning: argocd-server deployment not ready yet, continuing to port-forward..."
}
echo "Forwarding local port 8080 -> argocd-server:443 (use Ctrl-C to stop)"
kubectl -n argocd port-forward svc/argocd-server 8080:443