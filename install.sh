#!/usr/bin/env bash
set -euo pipefail

# Ensure Homebrew is installed
if ! command -v brew >/dev/null 2>&1; then
  echo "Homebrew not found. Install it from https://brew.sh first." >&2
  exit 1
fi

brew install zsh
brew install --cask wezterm
brew install font-meslo-lg-nerd-font
brew install powerlevel10k
brew install zsh-autosuggestions
brew install zsh-syntax-highlighting
brew install eza
brew install zoxide
brew install fzf
brew install tmux



