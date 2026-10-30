---
name: claim-check
description: Check every claim in a page for its level (verified / experience / opinion), source, date, and hype or denial. Use before publishing a page, or when he asks if a page is honest.
argument-hint: "<path to a content page>"
---

# Claim check

Rules: `.claude/rules/voice.md` § Every claim has a level.

1. List each factual claim in the page, one line each.
2. Tag it: **Verified** (has a public, dated source), **Experience** (his generalized work), **Opinion** (labelled), or **Unsupported**.
3. For each Verified claim, open the source and confirm it says that. Dead or paywalled link: say so.
4. Flag hype ("replaces developers", "10x", "fully autonomous") and denial ("just autocomplete", "doesn't work on real code") when the page gives no evidence for it.
5. Flag missing dates on anything time-sensitive (tools, models, prices, market numbers).
6. Output a short table: claim · level · problem · fix. Then propose edits; apply them only on his yes.
