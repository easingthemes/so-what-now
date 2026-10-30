#!/usr/bin/env bash
# check-private.sh — block private names (clients, people, employer) from reaching
# this repo (public soon): file contents, file paths, commit messages, PR text.
#
# The denylist can never be committed (it would leak the names it protects),
# so it comes from outside the repo:
#   PRIVATE_DENYLIST       env — entries separated by newlines or commas
#                           (CI: a repository secret of the same name)
#   PRIVATE_DENYLIST_2 ... _9  more env parts, for env settings that cut long values
#   PRIVATE_DENYLIST_FILE  file, one entry per line, `#` comments
#                           (default: <repo>/.private-denylist, gitignored)
# Each entry is an extended regex matched case-insensitively, so a short name
# that is also an English word can be anchored: `\bacme\b`.
#
# Output never contains a matched term or the matching text, only where it is
# and which entry number matched: CI logs of a public repo are public too.
#
# Usage:
#   check-private.sh diff <base>        added lines + paths in <base>...HEAD,
#                                       and commit messages in <base>..HEAD
#   check-private.sh worktree           added lines vs HEAD (staged + unstaged)
#   check-private.sh staged             added lines in the index (pre-commit)
#   check-private.sh all                every tracked file, its path, all commit messages
#   check-private.sh text <label>       stdin (PR title/body, a command line)
#   check-private.sh files <path>...    whole file contents
#
# Exit: 0 clean (or no denylist configured), 1 match found, 2 usage error.
set -uo pipefail
# Byte-wise: diffs and files may hold any encoding; matching stays ASCII-case-insensitive.
export LC_ALL=C

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
MODE="${1:-}"; shift || true

# --- load denylist -----------------------------------------------------------
PATTERNS=()
add_entries() {
  local line
  while IFS= read -r line; do
    line="${line%%#*}"                                  # strip comments
    line="$(printf '%s' "$line" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
    [ -n "$line" ] && PATTERNS+=("$line")
  done
}
for var in PRIVATE_DENYLIST PRIVATE_DENYLIST_{2..9}; do
  [ -n "${!var:-}" ] && add_entries < <(printf '%s\n' "${!var}" | tr ',' '\n')
done
LIST_FILE="${PRIVATE_DENYLIST_FILE:-$ROOT/.private-denylist}"
[ -f "$LIST_FILE" ] && add_entries < "$LIST_FILE"

# An entry that matches plain English is broken (e.g. a value cut mid-entry):
# it would flag everything. Skip it and say which one.
PROBE="the quick brown fox jumps over a lazy dog while we write code and docs"
KEPT=()
for i in "${!PATTERNS[@]}"; do
  if printf '%s\n' "$PROBE" | grep -qiE -- "${PATTERNS[$i]}"; then
    echo "check-private: denylist entry #$((i + 1)) matches ordinary text — skipped, fix the list" >&2
  else
    KEPT+=("${PATTERNS[$i]}")
  fi
done
PATTERNS=("${KEPT[@]}")

if [ "${#PATTERNS[@]}" -eq 0 ]; then
  echo "check-private: no denylist configured (PRIVATE_DENYLIST / $LIST_FILE) — skipped" >&2
  exit 0
fi

# --- collect "<label>\t<text>" lines to scan ---------------------------------
SRC="$(mktemp)"; trap 'rm -f "$SRC"' EXIT

# Added lines of a unified diff, labelled path:newLineNumber; each path is also
# scanned on its own so a file named after a client is caught too.
diff_lines() {
  awk '
    /^\+\+\+ / { f=$2; sub(/^b\//, "", f); if (f != "/dev/null") print f "\t" f; next }
    /^@@ /     { split($3, a, ","); n=substr(a[1], 2) + 0; next }
    /^\+/      { print f ":" n "\t" substr($0, 2); n++; next }
    /^ /       { n++ }
  '
}

case "$MODE" in
  diff)
    BASE="${1:?base ref required}"
    git -C "$ROOT" diff --no-color --unified=0 "$BASE"...HEAD | diff_lines >> "$SRC"
    git -C "$ROOT" log --format='%h%x09%B%x00' "$BASE"..HEAD \
      | awk 'BEGIN{RS="\0"} NF { split($0, p, "\t"); sha=p[1]; sub(/^[^\t]*\t/, "");
               n=split($0, l, "\n"); for (i=1;i<=n;i++) if (l[i] != "") print "commit " sha " message\t" l[i] }' >> "$SRC"
    ;;
  worktree)
    git -C "$ROOT" diff --no-color --unified=0 HEAD | diff_lines >> "$SRC"
    ;;
  staged)
    git -C "$ROOT" diff --no-color --unified=0 --cached | diff_lines >> "$SRC"
    ;;
  all)
    while IFS= read -r f; do
      printf '%s\t%s\n' "$f" "$f" >> "$SRC"
      [ -f "$ROOT/$f" ] && grep -Iq . "$ROOT/$f" 2>/dev/null && awk -v l="$f" '{ print l ":" NR "\t" $0 }' "$ROOT/$f" >> "$SRC"
    done < <(git -C "$ROOT" ls-files)
    git -C "$ROOT" log --format='%h%x09%B%x00' \
      | awk 'BEGIN{RS="\0"} NF { split($0, p, "\t"); sha=p[1]; sub(/^[^\t]*\t/, "");
               n=split($0, l, "\n"); for (i=1;i<=n;i++) if (l[i] != "") print "commit " sha " message\t" l[i] }' >> "$SRC"
    ;;
  text)
    LABEL="${1:-stdin}"
    awk -v l="$LABEL" '{ print l ":" NR "\t" $0 }' >> "$SRC"
    ;;
  files)
    [ "$#" -gt 0 ] || { echo "files: no paths given" >&2; exit 2; }
    for f in "$@"; do
      [ -f "$f" ] && grep -Iq . "$f" 2>/dev/null && awk -v l="$f" '{ print l ":" NR "\t" $0 }' "$f" >> "$SRC"
    done
    ;;
  *)
    sed -n '2,/^set -uo/p' "$0" | sed '$d' | sed 's/^# \{0,1\}//' >&2
    exit 2
    ;;
esac

# --- match --------------------------------------------------------------------
# Split into parallel files so grep sees only the text, and report by label.
LABELS="$(mktemp)"; TEXTS="$(mktemp)"; trap 'rm -f "$SRC" "$LABELS" "$TEXTS"' EXIT
cut -f1 "$SRC" > "$LABELS"
cut -f2- "$SRC" > "$TEXTS"
HITS=0
for i in "${!PATTERNS[@]}"; do
  while IFS= read -r n; do
    echo "LEAK: $(sed -n "${n}p" "$LABELS") matches denylist entry #$((i + 1))"
    HITS=$((HITS + 1))
  done < <(grep -niE -- "${PATTERNS[$i]}" "$TEXTS" | cut -d: -f1)
done

if [ "$HITS" -gt 0 ]; then
  echo "check-private: $HITS match(es). This repo is public soon — generalize per .claude/rules/privacy.md (no clients, people, employer details)." >&2
  exit 1
fi
exit 0
