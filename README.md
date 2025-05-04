# Dotfiles

My personal dotfiles managed with GNU Stow.

## Overview

This repository contains my configuration files (dotfiles) for various tools and applications. The configuration is organized into modules that can be individually linked to your home directory using GNU Stow.

## Requirements

- [GNU Stow](https://www.gnu.org/software/stow/)
- [Homebrew](https://brew.sh/) (for macOS users)

## Installation

### Quick Start

Clone the repository and run the installation script:

```bash
git clone https://github.com/ravilushqa/dotfiles.git
cd dotfiles
make install
```

### Manual Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/ravilushqa/dotfiles.git ~/.dotfiles
   cd ~/.dotfiles
   ```

2. Install Homebrew (if not already installed):
   ```bash
   make homebrew
   ```

3. Install packages from Brewfile:
   ```bash
   make brew-bundle
   ```

4. Stow configurations:
   ```bash
   make stow
   ```

5. Set up personal Git configuration:
   ```bash
   make git-local
   ```

## Available Modules

- **zsh**: Configuration for Z shell, including aliases, functions, and prompt
- **git**: Git configuration, with separate files for aliases, user settings, etc.

## Structure

```
dotfiles/
├── Brewfile          # Homebrew packages
├── Makefile          # Automation scripts
├── git/              # Git configuration
│   ├── .gitconfig    # Main Git config
│   └── .config/git/  # Modular Git configurations
└── zsh/              # Zsh configuration
    ├── .zshrc        # Main Zsh config
    └── .p10k.zsh     # Powerlevel10k configuration
```

## Customization

### Git

Edit `git/.config/git/config.user` to configure your Git identity.

### Zsh

Edit `zsh/.zshrc.local` for machine-specific Zsh configurations.

## Maintenance

- To update all stowed configurations: `make stow`
- To update Homebrew packages: `make update`
- To install new Homebrew packages: `make brew-bundle`

## License

MIT