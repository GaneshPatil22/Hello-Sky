---
description: Commit staged or unstaged changes with a title, one-line description, and 3 bullets
allowed-tools: Bash(git status:*), Bash(git diff:*), Bash(git add:*), Bash(git commit:*), Bash(git log:*), Bash(git branch:*)
---

## Context

- Status: !`git status --short`
- Staged diff: !`git diff --cached --stat`
- Unstaged diff: !`git diff --stat`
- Recent commits: !`git log --oneline -10`

## Task

Commit the current changes. $ARGUMENTS

1. Read the full diff (`git diff` and `git diff --cached`) to understand what actually changed. Do not rely on the stats above alone.
2. If nothing is staged, stage the relevant changed files. Never use `git add -A` or `git add .` blindly — skip build artifacts, `.DS_Store`, `xcuserdata/`, and anything unrelated to the change.
3. Write the message in exactly this shape:

```
<Title: imperative mood, under 60 chars, no trailing period>

<One sentence saying what changed and why.>

- <What changed, concretely>
- <What changed, concretely>
- <What changed, concretely>
```

4. Commit with a heredoc so the formatting survives:

```bash
git commit -F - <<'MSG'
...message...
MSG
```

## Rules

- Exactly three bullets. If the change is smaller than three bullets, the bullets describe distinct aspects of it (what, where, effect) rather than padding with filler.
- Bullets are short — one line each, no wrapping, no sub-bullets.
- Describe the change, not the process. "Raise deployment target to iOS 27", not "updated some settings as requested".
- **Never add a `Co-Authored-By` trailer, a "Generated with Claude Code" line, an emoji footer, or any other mention of Claude or AI.** The commit message ends with the third bullet.
- Do not push. Do not amend an existing commit unless explicitly asked.
- If a pre-commit hook rewrites files, re-stage and retry once, then report what the hook changed.
