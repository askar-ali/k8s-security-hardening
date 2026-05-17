#!/usr/bin/env bash
# Run every audit and save a timestamped report under reports/ (git-ignored).
set -euo pipefail
cd "$(dirname "$0")/.."

OUT="reports/audit-$(date +%Y%m%d-%H%M%S).txt"
mkdir -p reports
for s in audit/audit-*.sh; do
  echo "######## $(basename "$s") ########"
  "$s" || echo "(script exited non-zero)"
  echo
done | tee "$OUT"
echo "Saved $OUT"
