---
name: new-page
description: Create a new content page (Markdown under content/) with the right front matter, voice and claim levels. Use when he asks to write, start or draft a page, guide, chapter or article for the site.
argument-hint: "<topic> [section]"
---

# New page

1. Read `.claude/rules/content.md`, `voice.md`, `privacy.md`.
2. Ask only what you cannot infer: section, and whether the source is private experience (then use skill `generalize` for those parts).
3. Path: `content/<section>/<kebab-title>.md`. Front matter: `title`, `description`, `section`, `order`, `status: draft`, `updated: <today>`.
4. Structure: the problem in 1–2 sentences, then what works / what needs a human / what can be automated, then concrete next steps for the reader, then sources.
5. Mark claim levels as you write. Leave a visible `TODO(source)` instead of inventing a number.
6. Run `bash scripts/validate.sh`. Show him the page; `status: published` only on his word.
7. If the page belongs to a GitHub issue, mention the issue number in the commit message.
