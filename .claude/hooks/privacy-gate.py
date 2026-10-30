"""Privacy gate for this repo (public soon). PreToolUse hook.

Layer 1, every write: scripts/check-private.sh against the private denylist.
         A hit denies the call.
Layer 2, everything that leaves the machine (git push, GitHub writes):
         a model reads the outgoing text against .claude/rules/privacy.md.
         red -> deny, yellow or unsure -> ask the author, green -> allow.
Fails toward asking: if the model check breaks, the author decides.
"""
import json
import os
import re
import subprocess
import sys

ROOT = os.environ.get("CLAUDE_PROJECT_DIR") or os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
CHECK = os.path.join(ROOT, "scripts/check-private.sh")
RULES = os.path.join(ROOT, ".claude/rules/privacy.md")
REPO_NAME = "so-what-now"
MODEL = os.environ.get("PRIVACY_GATE_MODEL", "claude-sonnet-5-5")
MAX_PAYLOAD = 60000
READ_ONLY = re.compile(r"^mcp__github__(get_|list_|search_|issue_read|pull_request_read)")


def out(decision, reason):
    print(json.dumps({"hookSpecificOutput": {
        "hookEventName": "PreToolUse",
        "permissionDecision": decision,
        "permissionDecisionReason": reason,
    }}))
    sys.exit(0)


def run(args, stdin=None, cwd=ROOT, timeout=60):
    r = subprocess.run(args, input=stdin, capture_output=True, text=True, cwd=cwd, timeout=timeout)
    return r.returncode, r.stdout + r.stderr


def has_denylist():
    return any(k.startswith("PRIVATE_DENYLIST") and k != "PRIVATE_DENYLIST_FILE" and v
               for k, v in os.environ.items()) or os.path.isfile(
        os.environ.get("PRIVATE_DENYLIST_FILE", os.path.join(ROOT, ".private-denylist")))


def denylist(mode, *args, stdin=None):
    """Return the scanner's report when it finds something, else None."""
    code, report = run(["bash", CHECK, mode, *args], stdin=stdin)
    return report.strip() if code == 1 else None


def model_check(payload):
    """Return (level, reason) from a model reading the payload against privacy.md."""
    truncated = len(payload) > MAX_PAYLOAD
    prompt = PROMPT.format(rules=open(RULES, encoding="utf-8").read(), payload=payload[:MAX_PAYLOAD])
    try:
        r = subprocess.run(["claude", "-p", "--model", MODEL], input=prompt, capture_output=True,
                           text=True, timeout=150, cwd="/tmp")
        verdict = json.loads(re.search(r"\{.*\}", r.stdout, re.S).group(0))
    except Exception as e:
        return "yellow", f"privacy gate: model check failed ({type(e).__name__}); check it yourself."
    level = verdict.get("verdict", "yellow")
    if truncated and level == "green":
        level = "yellow"
    lines = [f"privacy gate: {level.upper()}", verdict.get("summary", "")]
    for f in verdict.get("findings", [])[:8]:
        lines.append(f"- [{f.get('level')}] \"{f.get('quote', '')[:120]}\": {f.get('why', '')}")
    if truncated:
        lines.append("- content was truncated for the check; review the rest yourself")
    return level, "\n".join(l for l in lines if l)


PROMPT = """You are a privacy gate. The text below is about to be published to a GitHub repo that
will be public. Judge it ONLY against these rules:

<rules>
{rules}
</rules>

<outgoing>
{payload}
</outgoing>

Check every part: text, file names, commit messages, branch names, titles, links.
Return ONLY one JSON object, no prose:
{{"verdict": "green|yellow|red",
  "findings": [{{"level": "red|yellow", "quote": "<short exact quote>", "why": "<one line>"}}],
  "summary": "<one or two lines: what is leaving, in plain words>"}}
red = at least one RED item. yellow = YELLOW items or you are unsure. green = only GREEN content."""


def gate_outbound(payload, deny_report):
    if deny_report:
        out("deny", "privacy gate: denylist hit, nothing was sent.\n" + deny_report)
    level, reason = model_check(payload)
    if not has_denylist():
        level = "yellow" if level == "green" else level
        reason += "\n- no private denylist in this session (PRIVATE_DENYLIST / .private-denylist): names were not checked"
    if level == "red":
        out("deny", reason + "\nBlocked. Rewrite without the red parts.")
    if level == "yellow":
        out("ask", reason + "\nConfirm only if you agree.")
    sys.exit(0)


def git(*args):
    return run(["git", *args])[1]


def main():
    try:
        data = json.load(sys.stdin)
    except Exception:
        sys.exit(0)
    tool, inp = data.get("tool_name", ""), data.get("tool_input", {}) or {}

    if tool in ("Write", "Edit", "MultiEdit"):
        path = os.path.abspath(inp.get("file_path", ""))
        if not path.startswith(ROOT + os.sep) or os.path.basename(path) == ".private-denylist":
            sys.exit(0)
        text = inp.get("content") or inp.get("new_string") or ""
        text += "".join(e.get("new_string", "") for e in inp.get("edits", []) or [])
        hit = denylist("text", os.path.relpath(path, ROOT), stdin=os.path.relpath(path, ROOT) + "\n" + text)
        if hit:
            out("deny", "privacy gate: this write contains a denylisted name. Generalize it (see .claude/rules/privacy.md).\n" + hit)
        sys.exit(0)

    if tool == "Bash":
        cmd = inp.get("command", "")
        if not re.search(r"\bgit\b[^|;&]*\b(commit|push)\b|\bgh\b", cmd):
            sys.exit(0)
        hit = denylist("text", "command", stdin=cmd)
        if re.search(r"\bgit\b[^|;&]*\bcommit\b", cmd):
            hit = hit or denylist("worktree")
            if hit:
                out("deny", "privacy gate: denylist hit in the commit, nothing was committed.\n" + hit)
        if re.search(r"\bgit\b[^|;&]*\bpush\b", cmd):
            run(["git", "fetch", "-q", "origin", "main"], timeout=60)
            hit = hit or denylist("diff", "origin/main")
            branch = git("rev-parse", "--abbrev-ref", "HEAD").strip()
            payload = (f"COMMAND:\n{cmd}\n\nBRANCH: {branch}\n\nCOMMITS:\n"
                       + git("log", "--format=%h %an <%ae>%n%B", "origin/main..HEAD")
                       + "\nDIFF vs origin/main:\n" + git("diff", "origin/main...HEAD"))
            gate_outbound(payload, hit)
        if hit:
            out("deny", "privacy gate: denylist hit in the command.\n" + hit)
        sys.exit(0)

    if tool.startswith("mcp__github__") and not READ_ONLY.match(tool):
        blob = json.dumps(inp, ensure_ascii=False)
        if str(inp.get("repo", "")).lower() != REPO_NAME and REPO_NAME not in blob.lower():
            sys.exit(0)
        gate_outbound(f"GITHUB TOOL: {tool}\nINPUT:\n{blob}", denylist("text", tool, stdin=blob))
    sys.exit(0)


if __name__ == "__main__":
    main()
