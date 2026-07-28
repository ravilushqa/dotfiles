#!/usr/bin/env bash
#
# Cold-start bootstrap for a brand-new Mac.
#
#   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/ravilushqa/dotfiles/main/bootstrap.sh)"
#
# Installs Homebrew (which pulls in the Xcode Command Line Tools + git), clones this
# repo, and runs `make install`. Safe to re-run; idempotent.

set -euo pipefail

REPO_URL="https://github.com/ravilushqa/dotfiles.git"
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"

info() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
die()  { printf '\033[1;31m✗\033[0m %s\n' "$*" >&2; exit 1; }

# 1. Homebrew — its installer also installs the Xcode Command Line Tools (and git)
#    non-interactively, so we don't need a separate GUI CLT prompt.
if ! command -v brew >/dev/null 2>&1 \
	&& [ ! -x /opt/homebrew/bin/brew ] && [ ! -x /usr/local/bin/brew ]; then
	info "Installing Homebrew (this also installs the Xcode Command Line Tools)..."
	NONINTERACTIVE=1 /bin/bash -c \
		"$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Put brew on PATH for the rest of this script (Apple Silicon or Intel).
if [ -x /opt/homebrew/bin/brew ]; then
	eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -x /usr/local/bin/brew ]; then
	eval "$(/usr/local/bin/brew shellenv)"
fi
command -v brew >/dev/null 2>&1 || die "Homebrew is not available on PATH after install."
command -v git  >/dev/null 2>&1 || die "git is not available (Xcode Command Line Tools missing?)."

# 2. Obtain the repo. If we're already running inside a checkout, use it.
if [ -f "./Makefile" ] && [ -f "./Brewfile" ] && [ -d "./zsh" ]; then
	DOTFILES_DIR="$(pwd)"
	info "Using existing checkout at $DOTFILES_DIR"
elif [ -d "$DOTFILES_DIR/.git" ]; then
	info "Repo already present at $DOTFILES_DIR"
else
	info "Cloning dotfiles into $DOTFILES_DIR"
	git clone "$REPO_URL" "$DOTFILES_DIR"
fi

# 3. Install everything.
info "Running 'make install' in $DOTFILES_DIR"
cd "$DOTFILES_DIR"
make install

cat <<'EOF'

──────────────────────────────────────────────
Bootstrap complete. A few manual follow-ups:

  1. Authenticate GitHub, then create + upload an SSH key:
       gh auth login
       make ssh-key

  2. Fill in machine-specific config:
       ~/.config/git/config.user   (Git name/email)
       ~/.zshrc.local              (env vars / secrets)

  3. Restart your shell:  exec zsh

  Casks that need admin rights (e.g. wifiman) may have prompted for
  your password; if any failed while unattended, re-run: make brew-bundle
──────────────────────────────────────────────
EOF
