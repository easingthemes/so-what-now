#!/usr/bin/env bash
# validate.sh — run before every commit: front matter of content pages + private-denylist scan.
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
rc=0

# Front matter: every content page needs title, description and a valid status.
while IFS= read -r f; do
  fm="$(awk 'NR==1 && $0!="---"{exit} NR>1 && $0=="---"{exit} NR>1{print}' "$f")"
  rel="${f#"$ROOT"/}"
  [ -n "$fm" ] || { echo "FRONT MATTER: $rel has none"; rc=1; continue; }
  for key in title description; do
    grep -qE "^$key:[[:space:]]*[^[:space:]]" <<<"$fm" || { echo "FRONT MATTER: $rel missing '$key'"; rc=1; }
  done
  status="$(sed -n 's/^status:[[:space:]]*//p' <<<"$fm" | tr -d '"'"'")"
  case "${status:-draft}" in draft|published) ;; *) echo "FRONT MATTER: $rel status '$status' (use draft|published)"; rc=1 ;; esac
done < <(find "$ROOT/content" -name '*.md' -type f | sort)

# Private names: uncommitted changes, and the whole tree when asked.
bash "$ROOT/scripts/check-private.sh" worktree || rc=1
[ "${1:-}" = "--all" ] && { bash "$ROOT/scripts/check-private.sh" all || rc=1; }

[ "$rc" -eq 0 ] && echo "validate: OK"
exit $rc
