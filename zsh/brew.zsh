# Homebrew environment.
# Must load BEFORE plugins.zsh so brew-installed tools (direnv, zoxide, fzf, etc.)
# are on PATH when their shell hooks initialize. Supports Apple Silicon and Intel.
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi
