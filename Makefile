SHELL := /usr/bin/env bash
.PHONY: all install install-macos install-linux detect-os check-dependencies install-zsh install-ohmyzsh install-zsh-plugins homebrew update brew-bundle stow

DOTFILES_DIR := $(CURDIR)
OS := $(shell uname -s)

all: install

install: detect-os
	@echo
	@echo "=========================================="
	@echo "Dotfiles installation complete!"
	@echo "Edit ~/.config/git/config.user with your Git identity."
	@echo "Run 'source ~/.zshrc' or restart your terminal."
	@echo

detect-os:
	@echo "==> Detecting operating system"
	@if [ "$(OS)" = "Darwin" ]; then \
		echo "✓ macOS detected"; \
		$(MAKE) install-macos; \
	elif [ "$(OS)" = "Linux" ]; then \
		echo "✓ Linux detected"; \
		$(MAKE) install-linux; \
	else \
		echo "✗ Unsupported operating system: $(OS)"; \
		exit 1; \
	fi

install-macos: homebrew update brew-bundle install-ohmyzsh install-zsh-plugins stow

install-linux: check-dependencies install-zsh install-ohmyzsh install-zsh-plugins stow

check-dependencies:
	@echo "==> Checking and installing dependencies"
	@if command -v apt-get >/dev/null 2>&1; then \
		echo "  -> Using apt package manager"; \
		sudo apt-get update; \
		sudo apt-get install -y git curl wget stow || exit 1; \
	elif command -v dnf >/dev/null 2>&1; then \
		echo "  -> Using dnf package manager"; \
		sudo dnf install -y git curl wget stow || exit 1; \
	elif command -v yum >/dev/null 2>&1; then \
		echo "  -> Using yum package manager"; \
		sudo yum install -y git curl wget stow || exit 1; \
	elif command -v pacman >/dev/null 2>&1; then \
		echo "  -> Using pacman package manager"; \
		sudo pacman -Sy --noconfirm git curl wget stow || exit 1; \
	else \
		echo "✗ No supported package manager found (apt, dnf, yum, pacman)"; \
		exit 1; \
	fi
	@echo "✓ Dependencies installed"

install-zsh:
	@echo "==> Installing zsh"
	@if ! command -v zsh >/dev/null 2>&1; then \
		if command -v apt-get >/dev/null 2>&1; then \
			sudo apt-get install -y zsh; \
		elif command -v dnf >/dev/null 2>&1; then \
			sudo dnf install -y zsh; \
		elif command -v yum >/dev/null 2>&1; then \
			sudo yum install -y zsh; \
		elif command -v pacman >/dev/null 2>&1; then \
			sudo pacman -S --noconfirm zsh; \
		else \
			echo "✗ Could not install zsh: no supported package manager"; \
			exit 1; \
		fi; \
		echo "✓ zsh installed"; \
	else \
		echo "✓ zsh is already installed"; \
	fi
	@echo "==> Setting zsh as default shell"
	@if [ "$$SHELL" != "$$(command -v zsh)" ]; then \
		echo "  -> Attempting to change default shell to zsh"; \
		if ! grep -q "$$(command -v zsh)" /etc/shells; then \
			echo "$$(command -v zsh)" | sudo tee -a /etc/shells; \
		fi; \
		sudo chsh -s "$$(command -v zsh)" $$USER || echo "  ⚠ Could not change shell automatically. Run: chsh -s $$(command -v zsh)"; \
	else \
		echo "✓ zsh is already the default shell"; \
	fi

install-ohmyzsh:
	@echo "==> Installing Oh My Zsh"
	@if [ ! -d "$$HOME/.oh-my-zsh" ]; then \
		echo "  -> Downloading and installing Oh My Zsh"; \
		sh -c "$$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended || exit 1; \
		echo "✓ Oh My Zsh installed"; \
	else \
		echo "✓ Oh My Zsh is already installed"; \
	fi
	@echo "==> Installing Powerlevel10k theme"
	@if [ ! -d "$$HOME/.oh-my-zsh/custom/themes/powerlevel10k" ]; then \
		git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $$HOME/.oh-my-zsh/custom/themes/powerlevel10k || exit 1; \
		echo "✓ Powerlevel10k theme installed"; \
	else \
		echo "✓ Powerlevel10k theme is already installed"; \
	fi

install-zsh-plugins:
	@echo "==> Installing zsh plugins"
	@if [ ! -d "$$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions" ]; then \
		echo "  -> Installing zsh-autosuggestions"; \
		git clone https://github.com/zsh-users/zsh-autosuggestions $$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions || exit 1; \
	else \
		echo "✓ zsh-autosuggestions already installed"; \
	fi
	@if [ ! -d "$$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" ]; then \
		echo "  -> Installing zsh-syntax-highlighting"; \
		git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting || exit 1; \
	else \
		echo "✓ zsh-syntax-highlighting already installed"; \
	fi
	@echo "✓ All zsh plugins installed"

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

	@echo "  -> Stowing zed configuration"
	@cd $(DOTFILES_DIR) && stow -v -t $(HOME) --adopt zed

	@echo "  -> Stowing alacritty configuration"
	@cd $(DOTFILES_DIR) && stow -v -t $(HOME) --adopt alacritty

	@echo "  -> Stowing claude configuration"
	@cd $(DOTFILES_DIR) && stow -v -t $(HOME) --adopt claude

	@echo "✓ Configuration files stowed successfully"
