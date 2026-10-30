---
name: privacy-check
description: Check a file, a draft, the working tree or the whole repo against the privacy rules before it is committed or published. Use before every commit in a multi-repo session (hooks are off there), before making the repo public, or when he asks "is this safe".
argument-hint: "[path | worktree | all]"
---

# Privacy check

1. Run the scanner: `bash scripts/check-private.sh worktree` (or `files <path>`, or `all` before the repo goes public). If it says no denylist is configured, tell him: names were not checked.
2. Read the content yourself against `.claude/rules/privacy.md`, RED then YELLOW. The scanner only knows names; you check meaning: an internal event, a negative career detail, a client that can be recognized from sector + size + date.
3. Report in short lines: `RED path:line — why`, `YELLOW path:line — question`. Never print a denylist entry.
4. Fix RED by generalizing (skill `generalize`). Ask about YELLOW. Then re-run step 1.
5. Before the repo goes public: `all` mode also scans every commit message. A RED hit in history needs a history rewrite: tell him, don't do it on your own.
