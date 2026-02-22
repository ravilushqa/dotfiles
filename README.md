# dotfiles

Personal dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Quick Start

```bash
git clone https://github.com/ravilushqa/dotfiles.git ~/dotfiles
cd ~/dotfiles
make install
```

## What's Included

| Package | Description |
|---------|-------------|
| `zsh` | Zsh config, aliases, plugins, p10k |
| `git` | Git config, global gitignore |
| `claude` | Claude Code agents, commands, statusline |
| `ghostty` | Ghostty terminal config |
| `alacritty` | Alacritty terminal config |
| `ssh` | SSH config |
| `zed` | Zed editor settings |

## Claude Code Setup

### Global MCP (`.mcp.json`)
Minimal — only Context7 for documentation lookup. Project-specific MCPs go in each repo's `.mcp.json`.

### Agents (`claude/.claude/agents/`)
- **code-reviewer** — strict Go code review (security, performance, production readiness)
- **debugger** — root cause analysis
- **find-bugs** — security and bug hunting on branch changes
- **terraform-architect** — IaC specialist

### Commands (`claude/.claude/commands/`)
- **`/code-review`** — comprehensive Go code quality review
- **`/commit`** — smart commit with Go pre-checks and conventional format
- **`/generate-tests`** — table-driven Go tests with mocks and benchmarks
- **`/create-architecture-documentation`** — architecture docs generator
- **`/plan`** — concise action plan for a coding task
- **`/address-pr-comments`** — address review feedback on current PR
- **`/iterate-pr`** — fix CI failures until green

### MCP for projects (`mcp.json`)
Template with Context7, GitHub, and K8s MCPs. Copy to project and fill in tokens.

## Adding a New Package

1. Create a directory: `mkdir mypackage`
2. Mirror the home directory structure inside it
3. Add stow command to `Makefile`
4. Run `make stow`
