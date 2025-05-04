# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
if [[ -n $SSH_CONNECTION ]]; then
  ZSH_THEME="afowler"
else
  ZSH_THEME="powerlevel10k/powerlevel10k"
fi

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

# User configuration

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# fzf
[[ -f $HOME/.fzf.zsh ]] && source $HOME/.fzf.zsh

# Custom functions
catall() {
  # Print the current working directory as the header
  echo -e "\e[1;32mCurrent Directory: $(pwd)\e[0m"
  if [ $# -eq 0 ]; then
    # Default: Show all files
    find . -type f -exec bash -c 'echo -e "\n\n\e[1;34m===== {} =====\e[0m"; bat --style=plain --paging=never "{}"' \;
  else
    # Loop through each extension
    for ext in "$@"; do
      find . -type f -name "*.${ext}" -exec bash -c 'echo -e "\n\n\e[1;34m===== {} =====\e[0m"; bat --style=plain --paging=never "{}"' \;
    done
  fi
}

drm() {
    docker rm -f $(docker ps -aq)
}

find_git_logs() {
    # Default value for days is 14 if no argument is provided
    days="${1:-14}"

    # The command with the configurable "days" variable
    find . -name '.git' -type d -prune -exec sh -c '
        repo="{}";
        repo_name=$(echo "$repo" | awk -F/ '\''{print $(NF-1)}'\'');
        cd "$repo/../" &&
        git_log_output=$(git log --author="ravil" --since="${0} day ago" --date=format:"%d.%m.%Y" --pretty=format:"%h - %ad : %s" 2>/dev/null);
        if [ -n "$git_log_output" ]; then
            printf "\nRepository: \033[1;35m$repo_name\033[0m\n$git_log_output\n";
        fi' "$days" \;
}

# Go configuration
export GOPATH=$HOME/go
export PATH=$PATH:$GOROOT/bin:$GOPATH/bin

# Local configurations and secrets (should be in .zshrc.local)
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

# direnv
if command -v direnv &> /dev/null; then
  eval "$(direnv hook zsh)"
fi

# 1Password CLI plugin
if [ -f "$HOME/.config/op/plugins.sh" ]; then
  source "$HOME/.config/op/plugins.sh"
fi
