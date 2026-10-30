#!/usr/bin/env bash
# Session start: wire the git pre-commit hook and say whether the private denylist is present.
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/../.." && pwd)}"
git -C "$ROOT" config core.hooksPath .githooks 2>/dev/null

echo "=== so-what-now: this repo will be PUBLIC ==="
echo "  Privacy rules: .claude/rules/privacy.md (no clients, people, employer details, private life)."
if [ -n "${PRIVATE_DENYLIST:-}${PRIVATE_DENYLIST_2:-}" ] || [ -f "${PRIVATE_DENYLIST_FILE:-$ROOT/.private-denylist}" ]; then
  echo "  Private denylist: loaded."
else
  echo "  WARNING: no private denylist (env PRIVATE_DENYLIST or .private-denylist)."
  echo "  Names are NOT checked by the scanner this session; only the model check on push runs. Tell the author."
fi
echo "  Planning lives in GitHub issues. Before commit: bash scripts/validate.sh"
