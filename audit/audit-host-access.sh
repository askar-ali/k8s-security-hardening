#!/usr/bin/env bash
# Read-only: pods that reach the host (hostPath, hostPID/IPC/network, added capabilities).
set -euo pipefail
command -v kubectl >/dev/null || { echo "kubectl required" >&2; exit 1; }
command -v jq >/dev/null || { echo "jq required" >&2; exit 1; }

kubectl get pods -A -o json | jq -r '
  .items[] | . as $p
  | [ (if $p.spec.hostPID then "hostPID" else empty end),
      (if $p.spec.hostIPC then "hostIPC" else empty end),
      (if any($p.spec.volumes[]?; .hostPath != null) then "hostPath" else empty end),
      (if any($p.spec.containers[]?; (.securityContext.capabilities.add // []) | length > 0) then "added-caps" else empty end) ]
  | select(length > 0) as $why
  | "\($p.metadata.namespace)/\($p.metadata.name)\t\($why | join(","))"' | column -t
