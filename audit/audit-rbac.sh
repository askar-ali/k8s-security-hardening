#!/usr/bin/env bash
# Read-only RBAC audit: cluster-admin bindings and wildcard roles.
set -euo pipefail
command -v kubectl >/dev/null || { echo "kubectl required" >&2; exit 1; }
command -v jq >/dev/null || { echo "jq required" >&2; exit 1; }

echo "== Subjects bound to cluster-admin =="
kubectl get clusterrolebindings -o json | jq -r '
  .items[] | select(.roleRef.name=="cluster-admin")
  | .metadata.name as $b
  | (.subjects // [])[] | "\($b)\t\(.kind)\t\(.namespace // "-")/\(.name)"' | column -t

echo
echo "== Roles/ClusterRoles with wildcard verbs or resources =="
for kind in clusterroles roles; do
  kubectl get "$kind" -A -o json 2>/dev/null || kubectl get "$kind" -o json
done | jq -r '
  .items[] | select(any(.rules[]?; (.verbs // [])|index("*")) or any(.rules[]?; (.resources // [])|index("*")))
  | "\(.kind)\t\(.metadata.namespace // "-")/\(.metadata.name)"' | sort -u | column -t

echo
echo "== Service accounts auto-mounting tokens (default SA per namespace) =="
kubectl get sa default -A -o json | jq -r '
  .items[] | select(.automountServiceAccountToken != false)
  | "\(.metadata.namespace)/default"'
