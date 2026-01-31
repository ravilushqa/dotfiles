# Main .zshrc file
# This file sources all modular configuration files

# Define the base directory for zsh configuration
# Dynamically determine the directory where this .zshrc is located
ZSH_CONFIG_DIR="${${(%):-%x}:a:h}"

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

# Added by Antigravity
export PATH="/Users/r.galaktionov/.antigravity/antigravity/bin:$PATH"
