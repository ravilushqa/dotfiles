SHELL := /usr/bin/env bash
.PHONY: all install homebrew update brew-bundle stow git-local work

DOTFILES_DIR := $(CURDIR)

all: install

install: homebrew update brew-bundle stow git-local work
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
	@echo "✓ Configuration files stowed successfully"

git-local:
	@echo "==> Setting up git local configuration"
	@if [ ! -f "$(DOTFILES_DIR)/git/.config/git/config.user" ]; then \
		cp $(DOTFILES_DIR)/git/.config/git/config.user.example $(DOTFILES_DIR)/git/.config/git/config.user; \
		echo "✓ Created git/.config/git/config.user"; \
		echo "ℹ Please edit git/.config/git/config.user with your git credentials"; \
	else \
		echo "✓ git/.config/git/config.user already exists"; \
	fi

work:
	@echo "==> Setting up work-specific configurations"
	@if [ ! -f "$(HOME)/.zshrc.local" ] && [ -f "$(DOTFILES_DIR)/zsh/.zshrc.local.example" ]; then \
		cp $(DOTFILES_DIR)/zsh/.zshrc.local.example $(HOME)/.zshrc.local; \
		echo "✓ Created ~/.zshrc.local"; \
		echo "ℹ Please edit ~/.zshrc.local with your work-specific settings"; \
	else \
		echo "ℹ Skipping .zshrc.local creation"; \
	fi
