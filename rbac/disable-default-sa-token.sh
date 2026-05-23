#!/usr/bin/env bash
# Stop the default ServiceAccount in every namespace from auto-mounting API tokens.
# Dry run by default. Usage: disable-default-sa-token.sh [--apply]
set -euo pipefail
command -v kubectl >/dev/null || { echo "kubectl required" >&2; exit 1; }

MODE="--dry-run=client"
[[ "${1:-}" == "--apply" ]] && MODE=""

for ns in $(kubectl get ns -o jsonpath='{.items[*].metadata.name}'); do
  # shellcheck disable=SC2086
  kubectl patch sa default -n "$ns" $MODE -p '{"automountServiceAccountToken": false}'
done
