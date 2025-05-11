# Main .zshrc file
# This file sources all modular configuration files

# Define the base directory for zsh configuration
ZSH_CONFIG_DIR="$HOME/projects/dotfiles/zsh"

# Source theme configuration (should be first for instant prompt)
source $ZSH_CONFIG_DIR/powerlevel10k.zsh

# Source plugin configurations
source $ZSH_CONFIG_DIR/plugins.zsh

# Source custom functions
source $ZSH_CONFIG_DIR/custom_functions.zsh

# Source aliases
source $ZSH_CONFIG_DIR/aliases.zsh

# Source path configurations
source $ZSH_CONFIG_DIR/path.zsh

# Source local configurations (should be last)
source $ZSH_CONFIG_DIR/local.zsh
