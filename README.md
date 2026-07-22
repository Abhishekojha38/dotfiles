# 🚀 Dotfiles

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![macOS](https://img.shields.io/badge/os-macOS-green.svg?logo=apple)]()
[![WezTerm](https://img.shields.io/badge/Terminal-WezTerm-blue?logo=alacritty)]()
[![Tmux](https://img.shields.io/badge/Multiplexer-Tmux-1ABB9C?logo=tmux)]()
[![Neovim](https://img.shields.io/badge/Editor-Neovim-57A143?logo=neovim)]()

A curated set of personal configuration files for an optimized, aesthetically pleasing, and highly productive terminal experience.

## ✨ Features

- **Terminal Emulator:** [WezTerm](https://wezfurlong.org/wezterm/) - GPU-accelerated cross-platform terminal emulator and multiplexer.
- **Terminal Multiplexer:** [tmux](https://github.com/tmux/tmux) - Customized for ease of use with intuitive keybindings and mouse support.
- **Text Editor:** [Neovim](https://neovim.io/) - Hyperextensible Vim-based text editor.
- **Shell Enhancements:** Zsh with `powerlevel10k` theme, `zsh-autosuggestions`, and `zsh-syntax-highlighting`.
- **Modern Utilities:** `eza` (modern replacement for `ls`), `zoxide` (smarter `cd` command), `fzf` (command-line fuzzy finder), and `herdr`.

---

## 🛠️ Installation

The provided `install.sh` script will automatically install Homebrew (if not present), all necessary packages and fonts, symlink the dotfiles to your home directory, and set Zsh as your default shell.

Simply clone the repository and run the install script:

```sh
# Clone the repository
git clone https://github.com/Abhishekojha38/dotfiles.git ~/dotfiles
cd ~/dotfiles

# Run the installation script
chmod +x install.sh
./install.sh
```

---

## 📄 License

This project is open source and available under the MIT License.
