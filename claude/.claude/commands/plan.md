---
allowed-tools: Read, Bash, Grep
description: Create a concise action plan for a coding task
---

# Plan: $ARGUMENTS

## Process
1. Scan context: README, docs, relevant code
2. Ask at most 1-2 blocking questions
3. Generate plan:

```
## Approach
<1-3 sentences: what and why>

## Scope
- In: ...
- Out: ...

## Action Items
[ ] Step 1
[ ] Step 2
...
[ ] Validation/testing step

## Open Questions
- (max 3)
```

Rules: each step is atomic, verb-first, names specific files when possible.
