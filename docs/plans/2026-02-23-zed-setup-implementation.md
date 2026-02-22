# Zed Editor Setup Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Make Zed a production-ready GoLand replacement by adding missing Brew tools, managing keymap/tasks configs in dotfiles, adding debug template, and configuring language support for Go/Terraform/Protobuf/SQL.

**Architecture:** Incremental enhancement of the existing Zed dotfiles setup. All config files live in `zed/.config/zed/` and are stow-linked to `~/.config/zed/`. Brew packages are managed in `Brewfile`. No tests — verification is JSON validation + symlink checks.

**Tech Stack:** Zed, GNU Stow, Homebrew, gopls, delve (DAP), terraform-ls, buf

---

### Task 1: Add missing Brew packages

**Files:**
- Modify: `Brewfile`

**Step 1: Add delve and terraform-ls to Brewfile**

In `Brewfile`, under the `# Go Development` section, add after `golangci-lint`:

```
brew "delve"           # Go debugger (DAP)
```

Under `# Infrastructure & DevOps`, add after `brew "tf"`:

```
brew "terraform-ls"    # Terraform language server (for Zed extension)
```

**Step 2: Install new packages**

```bash
brew bundle install --file=Brewfile
```

Expected: both `delve` and `terraform-ls` install without errors.

**Step 3: Verify**

```bash
which dlv && dlv version
which terraform-ls && terraform-ls --version
```

Expected: both print version strings.

**Step 4: Commit**

```bash
git add Brewfile
git commit -m "feat: add delve and terraform-ls to Brewfile"
```

---

### Task 2: Add keymap.json to dotfiles

`~/.config/zed/keymap.json` currently exists as an unmanaged file. We create the dotfiles version with updated content, remove the old file, then stow links it.

**Files:**
- Create: `zed/.config/zed/keymap.json`

**Step 1: Create keymap.json in dotfiles**

Create `zed/.config/zed/keymap.json` with this content (merges existing `shift shift` binding with new GoLand shortcuts):

```json
// Zed keymap
//
// For information on binding keys, see the Zed
// documentation: https://zed.dev/docs/key-bindings
//
// To see the default key bindings run `zed: open default keymap`
// from the command palette.
[
  {
    "context": "Workspace",
    "bindings": {
      "shift shift": "file_finder::Toggle"
    }
  },
  {
    "context": "Editor",
    "bindings": {
      "alt-enter": "editor::ToggleCodeActions",
      "cmd-alt-l": "editor::Format",
      "shift-f6": "editor::Rename",
      "cmd-shift-a": "command_palette::Toggle",
      "alt-f7": "editor::FindAllReferences"
    }
  }
]
```

**Step 2: Remove the unmanaged file**

```bash
rm ~/.config/zed/keymap.json
```

**Step 3: Run stow to link it**

```bash
cd ~/.dotfiles && stow -v -t $HOME --adopt zed
```

Expected output includes: `LINK: .config/zed/keymap.json => .../.dotfiles/zed/.config/zed/keymap.json`

**Step 4: Verify symlink**

```bash
ls -la ~/.config/zed/keymap.json
```

Expected: shows `->` pointing into `.dotfiles/zed/`.

**Step 5: Validate JSON**

```bash
jq . ~/.config/zed/keymap.json
```

Expected: prints formatted JSON without errors. (Note: Zed allows `//` comments in JSON, but `jq` will error on them — this is fine, the file is valid for Zed.)

**Step 6: Commit**

```bash
git add zed/.config/zed/keymap.json
git commit -m "feat: add keymap.json to dotfiles with GoLand shortcut gaps"
```

---

### Task 3: Create tasks.json in dotfiles

**Files:**
- Create: `zed/.config/zed/tasks.json`

**Step 1: Create tasks.json**

Create `zed/.config/zed/tasks.json`:

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

**Step 2: Run stow to link it**

```bash
cd ~/.dotfiles && stow -v -t $HOME --adopt zed
```

**Step 3: Verify symlink**

```bash
ls -la ~/.config/zed/tasks.json
```

Expected: symlink pointing into `.dotfiles/zed/`.

**Step 4: Validate JSON**

```bash
jq . ~/.config/zed/tasks.json
```

Expected: prints formatted JSON without errors.

**Step 5: Commit**

```bash
git add zed/.config/zed/tasks.json
git commit -m "feat: add tasks.json with Go run/test/lint configurations"
```

---

### Task 4: Create launch.json.template for debugging

This is a template to copy into individual projects as `.zed/launch.json`. It lives in dotfiles for reference but is NOT stow-linked (it's a template, not a config).

**Files:**
- Create: `zed/.config/zed/launch.json.template`

**Step 1: Create the template**

Create `zed/.config/zed/launch.json.template`:

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

**Usage note:** To enable debugging in a Go project, copy this file to `.zed/launch.json` in the project root and update `program` to point to your entry point (e.g., `./cmd/myapp`). Requires `delve` installed (`dlv`).

**Step 2: Commit**

```bash
git add zed/.config/zed/launch.json.template
git commit -m "feat: add launch.json.template for Go DAP debugging"
```

---

### Task 5: Update settings.json for new language support

Add terraform-ls and buf (proto formatter) configuration to `settings.json`.

**Files:**
- Modify: `zed/.config/zed/settings.json`

**Step 1: Add language server and formatter settings**

In `settings.json`, add a `"languages"` section after the `"lsp"` block:

```json
  "languages": {
    "HCL": {
      "language_servers": ["terraform-ls"],
      "formatter": {
        "language_server": {
          "name": "terraform-ls"
        }
      }
    },
    "Protobuf": {
      "formatter": {
        "external": {
          "command": "buf",
          "arguments": ["format", "-"]
        }
      }
    }
  }
```

**Step 2: Validate the full settings.json**

Zed uses JSONC (JSON with comments). Strip comments first, then validate:

```bash
sed 's|//.*||g' ~/.config/zed/settings.json | jq . > /dev/null && echo "Valid JSON"
```

Expected: `Valid JSON`

**Step 3: Commit**

```bash
git add zed/.config/zed/settings.json
git commit -m "feat: add terraform-ls and buf formatter to Zed settings"
```

---

### Task 6: Install Zed extensions (manual)

Extensions are installed via the Zed UI and are not managed in dotfiles (Zed stores them in `~/.config/zed/extensions/` automatically).

**Step 1: Open Zed extension manager**

In Zed: `cmd-shift-a` → type "zed: extensions" → Enter

Or: `cmd-shift-x` (Extensions panel)

**Step 2: Install each extension**

Search for and install:
- `terraform` — HCL syntax + terraform-ls integration
- `proto` — Protobuf syntax
- `sql` — SQL syntax highlighting
- `dockerfile` — Dockerfile support
- `env` — `.env` file support
- `toml` — TOML syntax (go.work, configs)

**Step 3: Verify in a test file**

- Open a `.tf` file → confirm syntax highlighting
- Open a `.proto` file → confirm syntax highlighting
- Open a `.sql` file → confirm syntax highlighting

**No commit needed** — extensions are managed by Zed internally.

---

### Task 7: Smoke test the full setup

**Step 1: Reload Zed config**

In Zed: `cmd-shift-a` → "zed: reload configuration"

**Step 2: Verify keymap bindings work**

- Open any file → press `alt-enter` → confirm code actions menu appears
- Press `cmd-alt-l` → confirm file formats
- Press `shift-f6` on a symbol → confirm rename dialog appears
- Press `alt-f7` → confirm find all references panel opens

**Step 3: Verify tasks work**

In a Go project: `cmd-shift-a` → "task: spawn" → select "Go: Test all" → confirm terminal runs `go test ./...`

**Step 4: Verify debug template**

In a Go project:
```bash
mkdir -p .zed && cp ~/.dotfiles/zed/.config/zed/launch.json.template .zed/launch.json
```
Update `program` path. In Zed: `cmd-shift-a` → "debug: start" → confirm debug panel appears.

**Step 5: Final commit (if any cleanup)**

```bash
git status  # should be clean
```
