#!/usr/bin/env bash
#
# Provisions a machine with the packages these dotfiles expect.
#
# This script does NOT deploy any configuration. The dotfiles are checked out
# directly into $HOME by the bare repository, so there is nothing to symlink.
# See README.md for the clone-and-checkout bootstrap, which runs first.
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🚀 Provisioning system..."

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

# 2. Install everything listed in the Brewfile
echo "📦 Installing packages from Brewfile..."
brew bundle install --file="$DOTFILES_DIR/Brewfile"

# 3. Set Zsh as default shell
BREW_ZSH="$(brew --prefix)/bin/zsh"
if ! grep -Fxq "$BREW_ZSH" /etc/shells; then
  echo "🔑 Adding Homebrew zsh to /etc/shells (requires sudo)..."
  echo "$BREW_ZSH" | sudo tee -a /etc/shells
fi

if [ "$SHELL" != "$BREW_ZSH" ] && [ "$SHELL" != "/bin/zsh" ]; then
  echo "🐚 Setting Zsh as the default shell..."
  chsh -s "$BREW_ZSH"
fi

echo "✅ Provisioning complete. Restart your terminal."
