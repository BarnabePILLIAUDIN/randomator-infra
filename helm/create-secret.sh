kubectl create secret docker-registry [secret-name] \
  --docker-server="[registry]" \
  --docker-username="[username]" \
  --docker-password="[token]" \
  --docker-email="[email]" \
  -n randomator