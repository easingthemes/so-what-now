# so-what-now

A practical, honest guide for ordinary web developers (frontend, backend, devops, QA) on how to get ready for agentic AI: what works today, what still needs a human, what can be automated, what to learn next, and how hiring really looks. Written from real enterprise delivery, by the author of `aem-mcp-server` and `dx-aem-flow`. Against hype and against denial.

**This repo is private now and will be public. Everything here, including git history, issues and PRs, is treated as public.**

## Rules (always loaded)

- **Privacy first:** `.claude/rules/privacy.md`. No clients, no people, no employers, nothing about the author beyond his public work. When unsure, leave it out and ask him in one line.
- **Voice and claims:** `.claude/rules/voice.md`. Every claim is Verified (dated source), Experience (generalized) or Opinion (labelled).
- **Content structure:** `.claude/rules/content.md`.

## Where things live

```
content/        all page text, Markdown + front matter (the website renders only this)
website/        Astro site, builds content/ to GitHub Pages
scripts/        check-private.sh (denylist scanner), validate.sh (run before commit)
.claude/        rules/, skills/ (new-page, generalize, privacy-check, claim-check), hooks/
.githooks/      pre-commit: denylist scan of staged lines
.github/        workflows: privacy.yml (denylist on every PR/push), deploy.yml (Pages)
```

Planning and todos: **GitHub issues**, not files. Issue text is public too.

## Working here

- **Private sources** (his notes, pasted stories, other private repos): skill `generalize`. Never copy text from them; rewrite. The removed items are listed in chat only.
- **Before commit:** `bash scripts/validate.sh`. In a session where this repo is not the root, hooks are off: say so once and run the check by hand.
- **Git:** never commit or push to `main`; work on a branch and open a PR. Before each commit/push, say the repo and branch in one line.
- **The private denylist** comes from env `PRIVATE_DENYLIST` (+ `_2`… parts) or the gitignored `.private-denylist`. Never read it into the conversation, never write an entry anywhere in this repo.
- Site preview: `cd website && npm install && npm run dev`. Build: `npm run build`.
- Talk to him in Serbian in chat if he writes in Serbian; site content is in English.
