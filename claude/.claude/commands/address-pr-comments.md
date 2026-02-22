---
allowed-tools: Read, Write, Edit, Bash, Grep
description: Address review comments on the current PR
---

# Address PR Comments

Address review feedback on the current branch's PR.

## Process

1. **Fetch comments**: `gh pr view --comments` and `gh api repos/{owner}/{repo}/pulls/{pr_number}/comments`
2. **Categorize**: Group by severity and effort
3. **Plan fixes**: Propose a fix for each comment, wait for confirmation if many
4. **Apply**: Make the code changes
5. **Respond**: Mark threads as resolved

## Rules
- Read surrounding code before applying fixes — understand context
- Verify `gh auth status` first
- Don't blindly apply all suggestions — some may be wrong
