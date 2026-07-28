SHELL := /usr/bin/env bash
.PHONY: all install homebrew update brew-taps brew-bundle omz stow local-config git-local zsh-local ssh-key

DOTFILES_DIR   := $(CURDIR)
# Resolve brew even when /opt/homebrew/bin isn't on PATH yet (fresh Apple Silicon Mac).
BREW           := $(shell command -v brew 2>/dev/null || echo /opt/homebrew/bin/brew)
STOW_MODULES   := zsh git ghostty ssh zed claude
OMZ_DIR        := $(HOME)/.oh-my-zsh
ZSH_CUSTOM_DIR := $(HOME)/.oh-my-zsh/custom
BACKUP_DIR     := $(HOME)/.dotfiles-backup-$(shell date +%Y%m%d-%H%M%S)
CUSTOM_TAPS    := dex4er/tap peonping/tap

all: install

install: homebrew brew-bundle omz stow local-config
	@echo
	@echo "=========================================="
	@echo "Dotfiles installation complete!"
	@echo
	@echo "Next steps:"
	@echo "  • Edit ~/.config/git/config.user with your Git identity"
	@echo "  • Edit ~/.zshrc.local with machine-specific env/secrets"
	@echo "  • Authenticate GitHub then create/upload an SSH key:"
	@echo "      gh auth login && make ssh-key"
	@echo "  • Restart your shell (or: exec zsh)"
	@echo

homebrew:
	@echo "==> Checking for Homebrew"
	@if ! command -v brew >/dev/null 2>&1 && [ ! -x "$(BREW)" ]; then \
		echo "  -> Homebrew not found. Installing..."; \
		NONINTERACTIVE=1 /bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; \
	fi; \
	eval "$$($(BREW) shellenv)"; \
	if ! command -v brew >/dev/null 2>&1; then \
		echo "✗ Homebrew still not available on PATH"; exit 1; \
	fi; \
	echo "✓ Homebrew ready"

update:
	@echo "==> Updating Homebrew"
	@eval "$$($(BREW) shellenv)"; \
	brew update && brew upgrade && echo "✓ Homebrew updated"

brew-taps:
	@echo "==> Trusting custom Homebrew taps"
	@eval "$$($(BREW) shellenv)"; \
	for t in $(CUSTOM_TAPS); do \
		brew tap "$$t" >/dev/null 2>&1 || true; \
		brew trust "$$t" >/dev/null 2>&1 || true; \
		echo "  -> $$t"; \
	done; \
	echo "✓ Custom taps trusted"

brew-bundle: brew-taps
	@echo "==> Installing packages from Brewfile"
	@if [ ! -f "$(DOTFILES_DIR)/Brewfile" ]; then echo "✗ Brewfile not found"; exit 1; fi
	@eval "$$($(BREW) shellenv)"; \
	brew bundle install --file="$(DOTFILES_DIR)/Brewfile" \
		|| echo "⚠ Some packages failed (e.g. casks needing sudo like wifiman, or MDM-managed apps). Re-run in a terminal or install those manually."; \
	echo "✓ brew bundle finished"

omz:
	@echo "==> Setting up oh-my-zsh"
	@if [ ! -d "$(OMZ_DIR)" ]; then \
		echo "  -> installing oh-my-zsh"; \
		RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c "$$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended; \
	else \
		echo "  -> oh-my-zsh already installed"; \
	fi
	@custom="$${ZSH_CUSTOM:-$(ZSH_CUSTOM_DIR)}"; \
	mkdir -p "$$custom/plugins" "$$custom/themes"; \
	[ -d "$$custom/themes/powerlevel10k" ] \
		|| git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$$custom/themes/powerlevel10k"; \
	[ -d "$$custom/plugins/zsh-autosuggestions" ] \
		|| git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions.git "$$custom/plugins/zsh-autosuggestions"; \
	[ -d "$$custom/plugins/zsh-syntax-highlighting" ] \
		|| git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git "$$custom/plugins/zsh-syntax-highlighting"; \
	echo "✓ oh-my-zsh + theme + plugins ready"

stow:
	@echo "==> Stowing configuration files"
	@if ! command -v stow >/dev/null 2>&1; then \
		echo "✗ GNU Stow not found. Run 'make brew-bundle' first (stow is in the Brewfile)."; exit 1; \
	fi
	@mkdir -p "$(HOME)/.config" "$(HOME)/Library/Application Support"
	@for m in $(STOW_MODULES); do \
		echo "  -> $$m"; \
		( cd "$(DOTFILES_DIR)/$$m" && find . -type f | sed 's|^\./||' ) | while read -r rel; do \
			tgt="$(HOME)/$$rel"; \
			[ -e "$$tgt" ] || continue; \
			real="$$(python3 -c 'import os,sys; print(os.path.realpath(sys.argv[1]))' "$$tgt" 2>/dev/null || echo "$$tgt")"; \
			case "$$real" in "$(DOTFILES_DIR)"/*) continue;; esac; \
			echo "     backing up existing $$rel -> $(BACKUP_DIR)/$$rel"; \
			mkdir -p "$(BACKUP_DIR)/$$(dirname "$$rel")"; \
			mv "$$tgt" "$(BACKUP_DIR)/$$rel"; \
		done; \
		stow -R -v -t "$(HOME)" -d "$(DOTFILES_DIR)" "$$m"; \
	done
	@echo "✓ Configuration files stowed"

# Scaffold machine-local files from their .example templates (never overwrites).
local-config: git-local zsh-local

git-local:
	@src="$(DOTFILES_DIR)/git/.config/git/config.user.example"; \
	dst="$(DOTFILES_DIR)/git/.config/git/config.user"; \
	if [ ! -f "$$dst" ]; then \
		cp "$$src" "$$dst"; echo "  -> created git config.user (edit name/email)"; \
	else echo "  -> git config.user already exists"; fi

zsh-local:
	@src="$(DOTFILES_DIR)/zsh/.zshrc.local.example"; \
	dst="$(HOME)/.zshrc.local"; \
	if [ ! -f "$$dst" ]; then \
		cp "$$src" "$$dst"; echo "  -> created ~/.zshrc.local (add machine-specific env/secrets)"; \
	else echo "  -> ~/.zshrc.local already exists"; fi

# Opt-in: generate an ed25519 key, add it to the keychain, and upload to GitHub via gh.
# Run after `gh auth login`. Idempotent.
ssh-key:
	@echo "==> SSH key setup"
	@key="$(HOME)/.ssh/id_ed25519"; \
	mkdir -p "$(HOME)/.ssh" && chmod 700 "$(HOME)/.ssh"; \
	if [ ! -f "$$key" ]; then \
		comment="$$(gh api user --jq .login 2>/dev/null || hostname)"; \
		ssh-keygen -t ed25519 -C "$$comment" -f "$$key" -N ""; \
		echo "  -> generated $$key"; \
	else echo "  -> key already exists"; fi; \
	ssh-add --apple-use-keychain "$$key" >/dev/null 2>&1 || true; \
	if ! command -v gh >/dev/null 2>&1; then \
		echo "  ⚠ gh not found — install it, run 'gh auth login', then 'make ssh-key'"; exit 0; fi; \
	body="$$(cut -d' ' -f2 < "$$key.pub")"; \
	if gh ssh-key list 2>/dev/null | grep -q "$$body"; then \
		echo "  -> public key already on GitHub"; \
	else \
		gh ssh-key add "$$key.pub" --title "$$(scutil --get ComputerName 2>/dev/null || hostname)" \
			&& echo "✓ public key uploaded to GitHub" \
			|| echo "  ⚠ upload failed — run: gh auth refresh -h github.com -s admin:public_key && make ssh-key"; \
	fi
