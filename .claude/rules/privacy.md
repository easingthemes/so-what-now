# Privacy — what may reach this repo

This repo will be public. Treat every file, path, commit message, branch name, issue, PR title and PR body as already public. Git history keeps everything.

The content comes from real enterprise work, and real work is under confidentiality, like for every consultant. **Default: generalize, and when unsure, leave it out and ask the author.**

## Out of scope — never

1. **Clients and projects:** names, brands, identifying details, codenames, internal tools, tickets, channels, repos, URLs, screenshots, logs or code from client work.
2. **People:** names of anyone met through work or privately. Roles only, when the role does not identify the person.
3. **Employers, past or present:** names and anything internal.
4. **The author himself beyond his public work:** his employment, career plans and personal life are not a topic of this site.
5. **Secrets:** tokens, keys, internal endpoints, `.env` content.

## Ask the author first

- Concrete numbers from real work, even anonymized.
- Sector or size of a client: could it combine into an identity?
- Opinions about a named vendor, company or product.

## Fine

- His public work: open-source repos, talks, posts, public profiles.
- Generalized experience: "on an enterprise CMS program", "a large consultancy", "a Fortune 500 client".
- Technical lessons, including failures of tools and experiments.
- Public sources with links, and opinions marked as opinion, including career advice for readers.

## Mechanics

- **Private source material:** never copy text. Rewrite for the public; list what you removed in chat only, never in a file.
- **Denylist:** names that must never appear live outside this repo (env `PRIVATE_DENYLIST`, plus `PRIVATE_DENYLIST_2`… when a long value is split, or the gitignored `.private-denylist`). Never write an entry anywhere in this repo, an issue, a PR or a commit message.
- `scripts/check-private.sh` scans against it. `.claude/hooks/privacy-gate.py` runs it on every write, commit, push and GitHub write, and on push also runs a model check against this file. CI `privacy.yml` runs it on every PR and push.
- Hooks run only when this repo is the session's root. Otherwise run `bash scripts/check-private.sh worktree` before every commit and say so.
- If something out of scope already landed: stop and tell the author; don't rewrite history on your own.
