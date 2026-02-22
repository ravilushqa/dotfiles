---
allowed-tools: Read, Write, Edit, Bash
description: Fix CI failures and iterate until all checks pass
---

# Iterate PR Until CI Passes

Fix CI failures on the current PR iteratively.

## Process

1. **Check CI**: `gh pr checks` — if pending, wait
2. **Get failures**: `gh run list --branch $(git branch --show-current) --limit 3` then `gh run view <id> --log-failed`
3. **Read actual logs** — don't guess from check names
4. **Fix** the issue
5. **Push** and repeat until green

## Rules
- Always read actual failure logs, not just check names
- Run local tests before pushing: `go test ./...`
- Don't fix the same thing twice — check if already addressed
