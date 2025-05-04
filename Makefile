SHELL := /usr/bin/env bash
.PHONY: all install homebrew update brew-bundle stow git-local work ghostty

DOTFILES_DIR := $(CURDIR)

all: install

install: homebrew update brew-bundle stow
	@echo
	@echo "=========================================="
	@echo "Dotfiles installation complete!"
	@echo "Edit ~/.gitconfig.local with your Git identity."
	@echo

homebrew:
	@echo "==> Checking for Homebrew"
	@if ! command -v brew >/dev/null 2>&1; then \
		echo "ℹ Homebrew not found. Installing..."; \
		/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; \
		if ! command -v brew >/dev/null 2>&1; then \
			echo "✗ Failed to install Homebrew"; \
			exit 1; \
		fi; \
		echo "✓ Homebrew installed successfully"; \
	else \
		echo "✓ Homebrew is already installed"; \
	fi

update:
	@echo "==> Updating Homebrew"
	@brew update && echo "✓ Homebrew updated"

brew-bundle:
	@echo "==> Installing packages from Brewfile"
	@if [ -f "$(DOTFILES_DIR)/Brewfile" ]; then \
		if ! brew bundle --help >/dev/null 2>&1; then \
			echo "✗ brew bundle command not available"; exit 1; \
		fi; \
		brew bundle check >/dev/null 2>&1 || brew bundle install; \
		echo "✓ Packages installed"; \
	else \
		echo "✗ Brewfile not found"; \
		exit 1; \
	fi

stow:
	@echo "==> Stowing configuration files"
	@if ! command -v stow >/dev/null 2>&1; then \
		echo "✗ GNU Stow not found. Install it with 'brew install stow'"; \
		exit 1; \
	fi
	@echo "  -> Checking for fzf configuration"
	@if [ -f "$(HOME)/.fzf.zsh" ] && [ ! -f "$(DOTFILES_DIR)/zsh/.fzf.zsh" ]; then \
		cp $(HOME)/.fzf.zsh $(DOTFILES_DIR)/zsh/; \
		echo "  -> Copied .fzf.zsh to dotfiles"; \
	fi
	@echo "  -> Stowing zsh configuration"
	@cd $(DOTFILES_DIR) && stow -v -t $(HOME) --adopt zsh

	@echo "  -> Stowing git configuration"
	@cd $(DOTFILES_DIR) && stow -v -t $(HOME) --adopt git

	@echo "  -> Stowing ghostty configuration"
	@cd $(DOTFILES_DIR) && stow -v -t $(HOME) --adopt ghostty


	@echo "  -> Stowing ssh configuration"
	@cd $(DOTFILES_DIR) && stow -v -t $(HOME) --adopt ssh

	@echo "✓ Configuration files stowed successfully"
