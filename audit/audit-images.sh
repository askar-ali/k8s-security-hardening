#!/usr/bin/env bash
# Read-only: images using mutable tags or coming from outside the trusted registries.
# Usage: TRUSTED="ghcr.io registry.example.internal" ./audit-images.sh
set -euo pipefail
command -v kubectl >/dev/null || { echo "kubectl required" >&2; exit 1; }
command -v jq >/dev/null || { echo "jq required" >&2; exit 1; }

TRUSTED="${TRUSTED:-ghcr.io registry.example.internal}"
IMAGES="$(kubectl get pods -A -o json | jq -r '.items[] | .metadata.namespace as $n | .spec.containers[] | "\($n)\t\(.image)"' | sort -u)"

echo "== Images with :latest or no tag =="
awk -F'\t' '$2 !~ /:[^\/]+$/ || $2 ~ /:latest$/' <<<"$IMAGES" | column -t

echo
echo "== Images outside trusted registries ($TRUSTED) =="
pattern="^($(tr ' ' '|' <<<"$TRUSTED"))/"
awk -F'\t' -v p="$pattern" '$2 !~ p' <<<"$IMAGES" | column -t
