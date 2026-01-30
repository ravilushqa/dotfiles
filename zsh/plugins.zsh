# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
    fzf
    command-not-found
    golang
    eza
    k9s
    kubectl
    terraform
    gcloud
    sudo
    helm
)

source $ZSH/oh-my-zsh.sh

# fzf
[[ -f $HOME/.fzf.zsh ]] && source $HOME/.fzf.zsh

# 1Password CLI plugin
if [ -f "$HOME/.config/op/plugins.sh" ]; then
  source "$HOME/.config/op/plugins.sh"
fi

# direnv
if command -v direnv &> /dev/null; then
  eval "$(direnv hook zsh)"
fi

autoload -U compinit; compinit

eval "$(zoxide init zsh)"

# Fix key bindings for Linux terminals
bindkey "\e[3~" delete-char          # Delete key
bindkey "^[[3~" delete-char          # Delete key (alternative)
bindkey "\e[H" beginning-of-line     # Home key
bindkey "\e[F" end-of-line           # End key
bindkey "^[[H" beginning-of-line     # Home key (alternative)
bindkey "^[[F" end-of-line           # End key (alternative)
