# Main .zshrc file
# This file sources all modular configuration files

# Define the base directory for zsh configuration
ZSH_CONFIG_DIR="$HOME/projects/dotfiles/zsh"

# Source theme configuration (should be first for instant prompt)
source $ZSH_CONFIG_DIR/theme/powerlevel10k.zsh

# Source plugin configurations
source $ZSH_CONFIG_DIR/plugins/plugins.zsh

# Source custom functions
source $ZSH_CONFIG_DIR/functions/custom_functions.zsh

# Source path configurations
source $ZSH_CONFIG_DIR/path/path.zsh

# Source local configurations (should be last)
source $ZSH_CONFIG_DIR/core/local.zsh