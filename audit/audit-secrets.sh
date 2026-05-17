#!/usr/bin/env bash
# Read-only: secrets exposed via env vars, and secret-typed objects that look risky.
set -euo pipefail
command -v kubectl >/dev/null || { echo "kubectl required" >&2; exit 1; }
command -v jq >/dev/null || { echo "jq required" >&2; exit 1; }

echo "== Containers reading secrets through env vars (prefer mounted files) =="
kubectl get pods -A -o json | jq -r '
  .items[] | . as $p | $p.spec.containers[]
  | select(any(.env[]?; .valueFrom.secretKeyRef != null))
  | "\($p.metadata.namespace)/\($p.metadata.name)/\(.name)"' | sort -u

echo
echo "== Env vars with secret-looking names set in plain text =="
kubectl get pods -A -o json | jq -r '
  .items[] | . as $p | $p.spec.containers[]
  | .env[]? | select(.value != null and (.name | test("(?i)pass|secret|token|key")))
  | "\($p.metadata.namespace)/\($p.metadata.name)\t\(.name)"' | sort -u | column -t

echo
echo "== Legacy service-account token secrets =="
kubectl get secrets -A --field-selector type=kubernetes.io/service-account-token \
  -o custom-columns=NS:.metadata.namespace,NAME:.metadata.name --no-headers
