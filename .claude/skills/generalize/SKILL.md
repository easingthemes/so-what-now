---
name: generalize
description: Turn real-work experience (notes or a pasted story) into public-safe text for this repo. Use whenever the source is client work or anything not already public.
argument-hint: "<what to generalize, or a path to private notes>"
---

# Generalize private experience

Input: an experience from real work. Output: the lesson, publishable.

1. Read `.claude/rules/privacy.md` first. Default is do not share.
2. Find the **lesson**: what a web developer or a company can learn from it. If there is no lesson without the private details, stop and say so.
3. Rewrite from scratch. Never copy a sentence or a paragraph from the source.
   - Clients → "an enterprise client" / "a Fortune 500 client". People → roles or nothing. Employers → "a large consultancy", never a name, no internal events.
   - Numbers → a range, marked YELLOW, and only if the lesson needs them.
4. Mark the claim level (`.claude/rules/voice.md`): this is usually **Experience**.
5. Show the draft. Below it, **in chat only**, list what you removed, one line per item. Never write that list into a file.
6. List the YELLOW items as one-line questions. Nothing YELLOW goes in without his yes.
7. If you are unsure whether something is RED, it is.
