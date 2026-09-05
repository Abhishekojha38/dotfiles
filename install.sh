#!/usr/bin/env bash
set -euo pipefail

echo "🚀 Preparing system from scratch..."

# 1. Install Homebrew if not installed
if ! command -v brew >/dev/null 2>&1; then
  echo "🍺 Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  
  # Configure Homebrew in current session for Apple Silicon / Intel Macs
  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
else
  echo "🍺 Homebrew is already installed."
fi

# 2. Update Homebrew
echo "🔄 Updating Homebrew..."
brew update

# 3. Install packages
echo "📦 Installing packages..."
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
brew install neovim
brew install herdr

# 4. Configuration is already in place
# This repository is checked out with $HOME as its work tree, so every tracked
# file already sits where the tool that reads it looks. Nothing to symlink.

# 5. Set Zsh as default shell
BREW_ZSH="$(brew --prefix)/bin/zsh"
if ! grep -Fxq "$BREW_ZSH" /etc/shells; then
  echo "🔑 Adding Homebrew zsh to /etc/shells (requires sudo)..."
  echo "$BREW_ZSH" | sudo tee -a /etc/shells
fi

if [ "$SHELL" != "$BREW_ZSH" ] && [ "$SHELL" != "/bin/zsh" ]; then
  echo "🐚 Setting Zsh as the default shell..."
  chsh -s "$BREW_ZSH"
fi

echo "✅ System preparation complete! Please restart your terminal."
