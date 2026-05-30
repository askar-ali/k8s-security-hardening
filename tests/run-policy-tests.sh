#!/usr/bin/env bash
# Offline policy test with the Kyverno CLI: good pod passes, bad pod fails.
set -euo pipefail
cd "$(dirname "$0")/.."
command -v kyverno >/dev/null || { echo "install the kyverno CLI first" >&2; exit 1; }

kyverno apply policies/kyverno --resource tests/fixtures/good-pod.yaml
if kyverno apply policies/kyverno --resource tests/fixtures/bad-pod.yaml; then
  echo "bad-pod unexpectedly passed" >&2; exit 1
fi
echo "policy tests OK"
