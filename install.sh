#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status
set -e

# Directory where this script resides
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# List of dotfiles to symlink
files=(
  .bashrc
  .vimrc
  .gitconfig
  .tmux.conf
)

echo "Installing dotfiles from $DOTFILES_DIR to home directory"

for file in "${files[@]}"; do
  src="$DOTFILES_DIR/$file"
  dest="$HOME/$file"
  if [ -e "$dest" ] || [ -L "$dest" ]; then
    echo "Backing up existing $dest to $dest.bak"
    mv "$dest" "$dest.bak"
  fi
  echo "Creating symlink for $file"
  ln -s "$src" "$dest"
done

echo "Dotfiles installation complete!"