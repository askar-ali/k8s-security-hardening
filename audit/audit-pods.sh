#!/usr/bin/env bash
# Read-only pod audit: privileged, root, or privilege-escalation-capable containers.
set -euo pipefail
command -v kubectl >/dev/null || { echo "kubectl required" >&2; exit 1; }
command -v jq >/dev/null || { echo "jq required" >&2; exit 1; }

kubectl get pods -A -o json | jq -r '
  .items[] | . as $p
  | $p.spec.containers[]
  | { ns: $p.metadata.namespace, pod: $p.metadata.name, c: .name,
      priv: (.securityContext.privileged // false),
      esc:  (.securityContext.allowPrivilegeEscalation // true),
      root: ((.securityContext.runAsNonRoot // $p.spec.securityContext.runAsNonRoot // false) | not),
      hostnet: ($p.spec.hostNetwork // false) }
  | select(.priv or .esc or .root or .hostnet)
  | "\(.ns)/\(.pod)/\(.c)\tprivileged=\(.priv)\tescalation=\(.esc)\tmaybe-root=\(.root)\thostNetwork=\(.hostnet)"' | column -t

echo
echo "== Namespaces without Pod Security Admission enforce label =="
kubectl get ns -o json | jq -r '
  .items[] | select(.metadata.labels["pod-security.kubernetes.io/enforce"] == null)
  | .metadata.name'

echo
echo "== Namespaces without any NetworkPolicy =="
comm -23 \
  <(kubectl get ns -o name | sed 's#namespace/##' | sort) \
  <(kubectl get netpol -A -o json | jq -r '.items[].metadata.namespace' | sort -u)
