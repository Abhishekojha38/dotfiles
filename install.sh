#!/usr/bin/env bash
#
# Provisions macOS or Ubuntu/Debian with the packages these dotfiles expect.
#
# This script does not deploy configuration. Run deploy.sh from a regular clone,
# or use the bare repository checkout documented in README.md.
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOCAL_BIN="${HOME}/.local/bin"
LOCAL_OPT="${HOME}/.local/opt"
export PATH="$LOCAL_BIN:$PATH"

log() {
  printf '%s\n' "$1"
}

install_macos() {
  if ! command -v brew >/dev/null 2>&1; then
    log "Installing Homebrew..."
    /bin/bash -c \
      "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    if [[ -x /opt/homebrew/bin/brew ]]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -x /usr/local/bin/brew ]]; then
      eval "$(/usr/local/bin/brew shellenv)"
    fi
  else
    log "Homebrew is already installed."
  fi

  log "Installing packages from Brewfile..."
  brew bundle install --file="$DOTFILES_DIR/Brewfile"
}

install_apt_packages() {
  local missing_packages=()
  local packages=()
  local package

  mapfile -t packages < <(
    sed -e 's/[[:space:]]*#.*$//' -e '/^[[:space:]]*$/d' \
      "$DOTFILES_DIR/packages/ubuntu.txt"
  )

  for package in "${packages[@]}"; do
    if ! dpkg-query -W -f='${db:Status-Status}' "$package" 2>/dev/null |
      grep -Fqx "installed"; then
      missing_packages+=("$package")
    fi
  done

  if [[ "${#missing_packages[@]}" -eq 0 ]]; then
    log "Ubuntu/Debian packages are already installed."
    return
  fi

  log "Installing Ubuntu/Debian packages..."
  sudo apt-get update
  sudo apt-get install -y "${missing_packages[@]}"
}

install_wezterm_linux() {
  if command -v wezterm >/dev/null 2>&1; then
    return
  fi

  log "Installing WezTerm from its official APT repository..."
  curl -fsSL https://apt.fury.io/wez/gpg.key |
    sudo gpg --yes --dearmor -o /usr/share/keyrings/wezterm-fury.gpg
  printf '%s\n' \
    'deb [signed-by=/usr/share/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *' |
    sudo tee /etc/apt/sources.list.d/wezterm.list >/dev/null
  sudo chmod 644 /usr/share/keyrings/wezterm-fury.gpg
  sudo apt-get update
  sudo apt-get install -y wezterm
}

install_neovim_linux() {
  local archive
  local asset
  local current_version
  local install_dir

  if command -v nvim >/dev/null 2>&1; then
    current_version="$(nvim --version | sed -n '1s/^NVIM v//p')"
    if printf '%s\n%s\n' "0.11.0" "$current_version" | sort -VC; then
      log "Neovim $current_version is already installed."
      return
    fi
  fi

  case "$(uname -m)" in
    x86_64)
      asset="nvim-linux-x86_64"
      ;;
    aarch64 | arm64)
      asset="nvim-linux-arm64"
      ;;
    *)
      log "Unsupported architecture for the Neovim binary: $(uname -m)"
      return 1
      ;;
  esac

  mkdir -p "$LOCAL_BIN" "$LOCAL_OPT"
  archive="$(mktemp "${TMPDIR:-/tmp}/nvim.XXXXXX.tar.gz")"
  install_dir="$LOCAL_OPT/$asset"

  log "Installing the latest Neovim release..."
  curl -fL \
    "https://github.com/neovim/neovim/releases/latest/download/${asset}.tar.gz" \
    -o "$archive"
  rm -rf "$install_dir"
  tar -xzf "$archive" -C "$LOCAL_OPT"
  rm -f "$archive"
  ln -sfn "$install_dir/bin/nvim" "$LOCAL_BIN/nvim"
}

install_eza_linux() {
  local archive
  local asset
  local extract_dir

  if command -v eza >/dev/null 2>&1; then
    return
  fi

  case "$(uname -m)" in
    x86_64)
      asset="eza_x86_64-unknown-linux-gnu"
      ;;
    aarch64 | arm64)
      asset="eza_aarch64-unknown-linux-gnu"
      ;;
    *)
      log "Unsupported architecture for the eza binary: $(uname -m)"
      return 1
      ;;
  esac

  mkdir -p "$LOCAL_BIN"
  archive="$(mktemp "${TMPDIR:-/tmp}/eza.XXXXXX.tar.gz")"
  extract_dir="$(mktemp -d "${TMPDIR:-/tmp}/eza.XXXXXX")"

  log "Installing the latest eza release..."
  curl -fL \
    "https://github.com/eza-community/eza/releases/latest/download/${asset}.tar.gz" \
    -o "$archive"
  tar -xzf "$archive" -C "$extract_dir"
  install -m 755 \
    "$(find "$extract_dir" -type f -name eza -print -quit)" \
    "$LOCAL_BIN/eza"
  rm -rf "$archive" "$extract_dir"
}

install_fd_shim() {
  # Debian and Ubuntu ship fd as fdfind because the name fd is already taken.
  # Neovim plugins such as Telescope look for fd, so expose it under that name.
  if command -v fd >/dev/null 2>&1 || ! command -v fdfind >/dev/null 2>&1; then
    return
  fi

  log "Linking fdfind to fd in $LOCAL_BIN..."
  mkdir -p "$LOCAL_BIN"
  ln -sfn "$(command -v fdfind)" "$LOCAL_BIN/fd"
}

install_powerlevel10k() {
  local install_dir="${XDG_DATA_HOME:-$HOME/.local/share}/powerlevel10k"

  if [[ -d "$install_dir/.git" ]]; then
    log "Updating Powerlevel10k..."
    git -C "$install_dir" pull --ff-only
    return
  fi

  log "Installing Powerlevel10k..."
  mkdir -p "$(dirname "$install_dir")"
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
    "$install_dir"
}

install_hack_nerd_font() {
  local font_dir="${XDG_DATA_HOME:-$HOME/.local/share}/fonts/HackNerdFont"
  local archive

  if command -v fc-list >/dev/null 2>&1 &&
    fc-list ':family' | grep -Fi "Hack Nerd Font" >/dev/null; then
    return
  fi

  log "Installing Hack Nerd Font..."
  archive="$(mktemp "${TMPDIR:-/tmp}/HackNerdFont.XXXXXX.zip")"
  mkdir -p "$font_dir"
  curl -fL \
    https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Hack.zip \
    -o "$archive"
  unzip -oq "$archive" -d "$font_dir"
  rm -f "$archive"
  fc-cache -f "$font_dir"
}

install_optional_tools_linux() {
  if ! command -v herdr >/dev/null 2>&1; then
    log "Installing Herdr..."
    curl -fsSL https://herdr.dev/install.sh | sh
  fi

  if ! command -v copilot >/dev/null 2>&1; then
    log "Installing GitHub Copilot CLI..."
    curl -fsSL https://gh.io/copilot-install | bash
  fi

  if ! command -v claude >/dev/null 2>&1; then
    log "Installing Claude Code..."
    curl -fsSL https://claude.ai/install.sh | bash
  fi
}

install_linux() {
  if [[ ! -r /etc/os-release ]]; then
    log "Cannot identify this Linux distribution."
    return 1
  fi

  # shellcheck disable=SC1091
  source /etc/os-release
  if [[ "${ID:-}" != "ubuntu" && "${ID:-}" != "debian" &&
    " ${ID_LIKE:-} " != *" debian "* ]]; then
    log "Linux support currently covers Ubuntu and Debian."
    return 1
  fi

  install_apt_packages
  install_wezterm_linux
  install_neovim_linux
  install_eza_linux
  install_fd_shim
  install_powerlevel10k
  install_hack_nerd_font
  install_optional_tools_linux
}

set_default_shell() {
  local current_shell
  local zsh_path

  if [[ "$(uname -s)" == "Darwin" ]]; then
    zsh_path="$(brew --prefix)/bin/zsh"
    current_shell="$(dscl . -read "/Users/$(id -un)" UserShell |
      awk '{print $2}')"
  else
    zsh_path="$(command -v zsh)"
    current_shell="$(getent passwd "$(id -un)" | cut -d: -f7)"
  fi

  if ! grep -Fxq "$zsh_path" /etc/shells; then
    log "Adding $zsh_path to /etc/shells..."
    printf '%s\n' "$zsh_path" | sudo tee -a /etc/shells >/dev/null
  fi

  if [[ "$current_shell" != "$zsh_path" && "$current_shell" != "/bin/zsh" ]]; then
    if [[ ! -t 0 ]]; then
      log "Login shell unchanged in a non-interactive session."
      log "Run this command in a terminal: chsh -s $zsh_path"
      return
    fi

    log "Setting Zsh as the default shell..."
    chsh -s "$zsh_path"
  fi
}

log "Provisioning system..."
case "$(uname -s)" in
  Darwin)
    install_macos
    ;;
  Linux)
    install_linux
    ;;
  *)
    log "Unsupported operating system: $(uname -s)"
    exit 1
    ;;
esac

set_default_shell
log "Provisioning complete. Restart your terminal."
