# Content structure

- Every page is a Markdown file under `content/`. The folder path is the URL: `content/guides/start-here.md` → `/so-what-now/guides/start-here/`. `content/index.md` is the home page.
- The website (`website/`) only renders `content/`. Don't write page text inside `website/`.
- Front matter:

```yaml
---
title: Start here            # required
description: One sentence.   # required, used for SEO and cards
section: guides              # optional, groups pages in the nav
order: 10                    # optional, sort inside a section
status: draft                # draft | published — drafts are not built
updated: 2026-10-29          # date of the last real content change
---
```

- `status: draft` keeps a page off the website, **not** off GitHub. A draft is still public once the repo is public, so the privacy rules apply to drafts too.
- Links between pages: relative Markdown links to the `.md` file are fine on GitHub; on the site use `/so-what-now/<path>/`.
- New page: skill `new-page`. Before commit: `bash scripts/validate.sh`.
- Planning and todos live in GitHub issues, not in files. Issue text is public: same privacy rules.
