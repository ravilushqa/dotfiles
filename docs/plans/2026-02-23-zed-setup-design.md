# Zed Editor Setup Design

**Date:** 2026-02-23
**Goal:** Make Zed a production-ready replacement for GoLand (Go development, single-module monorepo, local debugging, Terraform/Protobuf/SQL support)

## Context

Existing base:
- Zed installed via Homebrew (`cask "zed"`)
- `settings.json` in dotfiles (stow-linked), with JetBrains base keymap, gopls configured, Nord theme, MCP servers
- `keymap.json` at `~/.config/zed/keymap.json` — not yet in dotfiles
- Nord theme in dotfiles

Approach: **Incremental enhancement** — fill gaps in existing setup without over-engineering.

## Design

### 1. Dotfiles Structure

Add `keymap.json` and `tasks.json` to dotfiles so they are stow-managed:

```
zed/
└── .config/
    └── zed/
        ├── settings.json   (already stow-linked)
        ├── keymap.json     (add to dotfiles)
        ├── tasks.json      (new)
        └── themes/
            └── nord.json
```

### 2. Extensions

Install via `zed: install extension`:

| Extension    | Purpose                          |
|-------------|----------------------------------|
| `terraform` | HCL syntax, formatting           |
| `proto`     | Protobuf syntax                  |
| `sql`       | SQL syntax highlighting          |
| `dockerfile`| Dockerfile support               |
| `env`       | `.env` file support              |
| `toml`      | `go.work`, config files          |

Go support is built-in via gopls — no extension needed.

Add to `Brewfile`:
- `delve` — Go debugger (DAP)
- `buf` — Protobuf linting/formatting
- `golangci-lint` — Go linter

### 3. Debugging (DAP + Delve)

Zed supports DAP via `delve` for Go. Configuration is per-project in `.zed/launch.json`.

Store a template at `zed/.config/zed/launch.json.template` in dotfiles to copy into projects:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "type": "go",
      "request": "launch",
      "name": "Launch package",
      "program": "${ZED_WORKTREE_ROOT}/cmd/server",
      "args": []
    },
    {
      "type": "go",
      "request": "launch",
      "name": "Test current file",
      "mode": "test",
      "program": "${ZED_FILE}"
    }
  ]
}
```

### 4. Keymap (`keymap.json`)

Base keymap is already `"base_keymap": "JetBrains"`. Add explicit bindings for gaps:

| GoLand shortcut | Action              | Zed keymap key  | Zed action                      |
|----------------|---------------------|-----------------|---------------------------------|
| `⌥ Enter`      | Quick fix           | `alt-enter`     | `editor::ToggleCodeActions`     |
| `⌘ ⌥ L`        | Reformat code       | `cmd-alt-l`     | `editor::Format`                |
| `⇧ F6`         | Rename              | `shift-f6`      | `editor::Rename`                |
| `⌘ ⇧ A`        | Find action         | `cmd-shift-a`   | `command_palette::Toggle`       |
| `⌥ F7`         | Find usages         | `alt-f7`        | `editor::FindAllReferences`     |
| `⌃ ⇧ T`        | Go to test          | `ctrl-shift-t`  | (via task)                      |
| `⇧ ⇧`          | Search everywhere   | `shift shift`   | `file_finder::Toggle` (already) |

### 5. Tasks (`tasks.json`)

```json
[
  {
    "label": "Go: Run",
    "command": "go run ./...",
    "reveal": "always"
  },
  {
    "label": "Go: Test all",
    "command": "go test ./...",
    "reveal": "always"
  },
  {
    "label": "Go: Test current file",
    "command": "go test $ZED_FILE",
    "reveal": "always"
  },
  {
    "label": "Go: Test with race",
    "command": "go test -race ./...",
    "reveal": "always"
  },
  {
    "label": "Go: Lint",
    "command": "golangci-lint run ./...",
    "reveal": "always"
  }
]
```

Triggered via `cmd-shift-a` → "task: spawn".

## Out of Scope

- Remote debugging (not needed — local only)
- Integrated DB client (GoLand/DataGrip feature — use external tool)
- HTTP client (use external tool or Zed extension separately)
- Multi-module monorepo support (single module only)
