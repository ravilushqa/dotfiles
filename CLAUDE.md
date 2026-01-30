# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

This is a personal dotfiles repository managed with GNU Stow. Configuration files are organized into modules (packages) that can be individually symlinked to the home directory. The repository includes configurations for zsh, git, terminal emulators (ghostty, alacritty), editors (zed), ssh, and Claude Code itself.

## Platform Support

This dotfiles repository works on both **macOS** and **Linux**:
- **macOS**: Uses Homebrew for package management and includes Mac-specific tools
- **Linux**: Supports multiple distributions via native package managers (apt, dnf, yum, pacman)

The `make install` command automatically detects your operating system and runs the appropriate installation steps. Both platforms receive:
- Zsh with Oh My Zsh framework
- Powerlevel10k theme
- Essential zsh plugins (autosuggestions, syntax highlighting)
- GNU Stow for symlink management
- All configuration files via stow packages

## Essential Commands

### Setup and Installation
```bash
# Full installation (auto-detects OS: macOS or Linux)
make install

# The install command automatically:
# - macOS: Installs Homebrew, packages from Brewfile, Oh My Zsh, plugins, and stows configs
# - Linux: Installs dependencies (git, curl, stow), zsh, Oh My Zsh, plugins, and stows configs

# Manual installation steps (if needed):

# Linux-specific commands:
make check-dependencies    # Install git, curl, wget, stow using apt/dnf/yum/pacman
make install-zsh          # Install zsh and set as default shell
make install-ohmyzsh      # Install Oh My Zsh and Powerlevel10k theme
make install-zsh-plugins  # Install zsh-autosuggestions and zsh-syntax-highlighting

# macOS-specific commands:
make homebrew             # Install Homebrew only
make update               # Update Homebrew
make brew-bundle          # Install/update packages from Brewfile

# Universal commands (both macOS and Linux):
make stow                 # Stow all configuration files (creates symlinks)
```

### Working with Individual Packages
```bash
# Stow a specific package manually
cd ~/.dotfiles
stow -v -t ~ --adopt <package_name>  # e.g., zsh, git, zed

# Unstow (remove symlinks) for a package
stow -v -t ~ -D <package_name>

# Restow (useful after making changes)
stow -v -t ~ --restow <package_name>
```

### Testing Changes
```bash
# Reload zsh configuration without restarting shell
source ~/.zshrc
# Or use the custom alias
reload

# Verify symlinks are correct
ls -la ~ | grep "\.dotfiles"
ls -la ~/.config | grep "\.dotfiles"
```

## Architecture and Structure

### GNU Stow Package System
Each top-level directory (except `.git`, `.claude`, etc.) represents a **stow package**:
- **zsh/**: Shell configuration files that get symlinked to `~/`
- **git/**: Git configuration, both in `~/` and `~/.config/git/`
- **ghostty/**: Terminal emulator config → `~/.config/ghostty/`
- **alacritty/**: Terminal emulator config → `~/.config/alacritty/`
- **zed/**: Editor settings → `~/.config/zed/`
- **ssh/**: SSH configuration → `~/.ssh/`
- **claude/**: Claude Code agents and commands → `~/.claude/`

**Key concept**: Files in each package directory mirror the structure they should have in `$HOME`. For example:
- `git/.gitconfig` → `~/.gitconfig`
- `zsh/.zshrc` → `~/.zshrc`
- `git/.config/git/config` → `~/.config/git/config`

### Git Configuration Modularity
Git configuration uses an include-based structure for better organization:
- `git/.gitconfig`: Entry point that includes `~/.config/git/config`
- `git/.config/git/config`: Main config that includes:
  - `config.core`: Aliases and core settings
  - `config.user`: User identity (customizable per machine)
  - `config.github`: GitHub-specific settings
  - `config.signing`: GPG/signing configuration
- `git/.config/git/config.user.example`: Template for user identity

When making Git configuration changes, edit the appropriate modular file rather than the main `.gitconfig`.

### Zsh Configuration Modularity
Zsh configuration is split into logical modules sourced by `.zshrc`:
- `.zshrc`: Entry point that sources all modules
- `powerlevel10k.zsh`: Theme configuration (must load first)
- `plugins.zsh`: Plugin management (fzf, zsh-autosuggestions, zoxide)
- `custom_functions.zsh`: Custom shell functions (catall, drm, find_git_logs)
- `aliases.zsh`: Command aliases (eza, bat, kubectx shortcuts)
- `path.zsh`: PATH and environment variables
- `local.zsh`: Machine-specific overrides (sources `.zshrc.local` if exists)

All modules are in the `zsh/` directory and are referenced by relative paths from `ZSH_CONFIG_DIR`.

### Claude Code Configuration
The `claude/` package contains custom agents and commands:
- **Agents** (`claude/.claude/agents/`): Specialized Go development experts
  - `golang-pro.md`: Production-ready Go development
  - `backend-architect.md`: API and microservice design
  - `code-reviewer.md`: Code quality and security
  - `database-architect.md`: Database schema and patterns
  - `terraform-architect.md`: Infrastructure as code
  - `debugger.md`: Debugging specialist
  - `task-decomposition-expert.md`: Complex task breakdown

- **Commands** (`claude/.claude/commands/`): Custom slash commands
  - `generate-tests.md`: Generate Go test suites
  - `code-review.md`: Comprehensive code review
  - `commit.md`: Well-formatted commits
  - `create-architecture-documentation.md`: Generate architecture docs
  - `sc/`: SuperClaude command collection (advanced features)

These agents and commands are available in Claude Code sessions that use this dotfiles repository.

## Development Tools Stack

### Primary Languages and Tools
- **Go**: Primary development language with tooling (golangci-lint, mockery)
- **Kubernetes**: kubectl, kubectx, k9s, helm, minikube, kustomize
- **Databases**: MongoDB (mongosh, compass), PostgreSQL, MySQL, Redis
- **Infrastructure**: Terraform (tfenv), Docker
- **CLI Tools**: fzf, fd, eza, zoxide, bat, jq, tree, htop

### Shell Environment
- **Shell**: Zsh with Powerlevel10k theme
- **Package Manager**:
  - macOS: Homebrew (managed via Brewfile)
  - Linux: Native package managers (apt, dnf, yum, pacman)
- **Terminal**: Ghostty (primary), Alacritty, Warp
- **Editor**: Zed (settings managed), Neovim, VS Code

## Important Patterns and Conventions

### Making Configuration Changes
1. Edit files directly in the package directories (e.g., `zsh/.zshrc`, `git/.config/git/config.core`)
2. Changes are immediately reflected via symlinks (no need to restow for edits)
3. For new files or structural changes, run `make stow` to update symlinks
4. Commit changes to version control: `git add . && git commit -m "description"`

### Adding New Configuration Files
To add a new config file to an existing package:
1. Place file in the appropriate package directory with the home-relative path
   - Example: To create `~/.config/foo/bar.conf`, create `<package>/.config/foo/bar.conf`
2. Run `make stow` to create the symlink
3. Verify: `ls -la ~/.config/foo/bar.conf` should point to `.dotfiles/<package>/.config/foo/bar.conf`

### Machine-Specific Customization
Files with `.local` or `.example` suffixes are for machine-specific overrides:
- `zsh/.zshrc.local.example`: Template for local zsh customization
- `zsh/.zshrc.local`: Machine-specific settings (not tracked or has local values)
- `git/.config/git/config.user`: Git identity (should be customized per machine)

### Custom Shell Functions
When adding shell functions to `zsh/custom_functions.zsh`:
- Use descriptive names with underscores (e.g., `find_git_logs`)
- Add comments explaining purpose and usage
- Test in a new shell session: `zsh` or `source ~/.zshrc`

### Notable Aliases and Functions
- `kctx`: kubectx shortcut
- `cat`: Aliased to `bat --pager=never` for syntax highlighting
- `cd`: Aliased to `z` (zoxide smart directory jumping)
- `ls`/`ll`/`lt`: eza with icons and colors
- `reload()`: Reload zsh configuration
- `catall()`: Print all files with syntax highlighting (supports extension filtering)
- `find_git_logs()`: Find git commits by author across all repos

## Testing and Validation

### After Making Changes
```bash
# Test zsh configuration
zsh -c 'echo "Zsh config loaded successfully"'

# Verify git configuration
git config --list --show-origin

# Check for broken symlinks
find ~ -maxdepth 1 -type l ! -exec test -e {} \; -print
find ~/.config -maxdepth 2 -type l ! -exec test -e {} \; -print

# Verify stow package status
cd ~/.dotfiles && stow -n -v -t ~ <package_name>  # Dry run, no changes
```

### Git Operations
Key git aliases from `config.core`:
- `git lg`: Pretty graph log with colors
- `git lol`: Compact log with signatures (last 25 commits)
- `git fza`: Interactive fzf-based file staging
- `git gone`: Delete local branches that have been deleted on remote
- `git st`: status
- `git co`: checkout
- `git br`: branch

## Repository Location
This repository should be located at `~/.dotfiles`. The Makefile uses `$(CURDIR)` so it works from any location, but `~/.dotfiles` is the standard convention. If you need to migrate from another location, see `MIGRATION_SPEC.md` for the complete migration procedure.
