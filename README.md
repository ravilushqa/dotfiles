# Dotfiles

My personal dotfiles managed with GNU Stow.

## Overview

This repository contains my configuration files (dotfiles) for various tools and applications. The configuration is organized into modules that can be individually linked to your home directory using GNU Stow.

## Platform Support

✅ **macOS** - Full support with Homebrew package management
✅ **Linux** - Full support for Debian/Ubuntu (apt), Fedora (dnf), RHEL/CentOS (yum), and Arch (pacman)

The installation script automatically detects your operating system and uses the appropriate package manager.

## Requirements

### Linux
- Git
- Curl
- GNU Stow

These will be automatically installed by `make install` using your distribution's package manager (apt, dnf, yum, or pacman).

### macOS
- [Homebrew](https://brew.sh/)
- Homebrew will automatically install GNU Stow and other dependencies

## Installation

### Quick Start

Clone the repository and run the installation script (works on both macOS and Linux):

```bash
git clone https://github.com/ravilushqa/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
make install
```

The installation process will:
1. Auto-detect your operating system (macOS or Linux)
2. Install required dependencies
3. Install and configure Zsh with Oh My Zsh
4. Install Powerlevel10k theme and essential plugins
5. Symlink all configuration files using GNU Stow

### Manual Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/ravilushqa/dotfiles.git ~/.dotfiles
   cd ~/.dotfiles
   ```

2. **For Linux users:**
   ```bash
   # Install dependencies (git, curl, stow)
   make check-dependencies

   # Install zsh and set as default shell
   make install-zsh

   # Install Oh My Zsh and Powerlevel10k
   make install-ohmyzsh

   # Install zsh plugins
   make install-zsh-plugins

   # Stow configurations
   make stow
   ```

3. **For macOS users:**
   ```bash
   # Install Homebrew (if not already installed)
   make homebrew

   # Install packages from Brewfile
   make brew-bundle

   # Install Oh My Zsh and plugins
   make install-ohmyzsh
   make install-zsh-plugins

   # Stow configurations
   make stow
   ```

4. **Set up personal Git configuration** (both platforms):
   ```bash
   # Edit your Git identity
   vim ~/.config/git/config.user
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

### All Platforms
- Update all stowed configurations: `make stow`

### macOS Only
- Update Homebrew: `make update`
- Install new Homebrew packages: `make brew-bundle`

### Linux
- Update system packages using your distribution's package manager:
  - Debian/Ubuntu: `sudo apt update && sudo apt upgrade`
  - Fedora: `sudo dnf update`
  - Arch: `sudo pacman -Syu`

## License

MIT