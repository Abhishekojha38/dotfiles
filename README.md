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

This repository is a bare Git repository whose work tree is your home
directory.
There are no symlinks and no deploy step: a checkout puts every file exactly
where the tool that reads it expects to find it.

### On a new machine

Run these in order. Each block is self-contained and safe to paste as is.

**1. Clone as a bare repository.**

```sh
git clone --bare https://github.com/Abhishekojha38/dotfiles.git "$HOME/dotfiles"
```

**2. Define the `dotfiles` command for this shell.**

```sh
dotfiles() { git --git-dir="$HOME/dotfiles" --work-tree="$HOME" "$@"; }
```

**3. Check the files out into `$HOME`.**

Anything already in the way is moved to `~/.dotfiles-backup/` first, keeping
its original sub-path, so nothing is lost and the checkout can succeed.

```sh
dotfiles checkout 2>&1 | awk '/^\t/ { sub(/^\t/, ""); print }' | while read -r f; do
  mkdir -p "$HOME/.dotfiles-backup/$(dirname "$f")"
  mv "$HOME/$f" "$HOME/.dotfiles-backup/$f"
done

dotfiles checkout
```

**4. Stop `dotfiles status` from listing your entire home directory.**

```sh
dotfiles config --local status.showUntrackedFiles no
```

**5. Install the packages and set the login shell.**

```sh
chmod +x "$HOME/install.sh" && "$HOME/install.sh"
```

**6. Restart the shell.**

`.zshrc` defines `dotfiles` permanently, so it is available from now on.

```sh
exec zsh
```

### All steps at once

```sh
git clone --bare https://github.com/Abhishekojha38/dotfiles.git "$HOME/dotfiles"
dotfiles() { git --git-dir="$HOME/dotfiles" --work-tree="$HOME" "$@"; }

dotfiles checkout 2>&1 | awk '/^\t/ { sub(/^\t/, ""); print }' | while read -r f; do
  mkdir -p "$HOME/.dotfiles-backup/$(dirname "$f")"
  mv "$HOME/$f" "$HOME/.dotfiles-backup/$f"
done

dotfiles checkout
dotfiles config --local status.showUntrackedFiles no
chmod +x "$HOME/install.sh" && "$HOME/install.sh"
exec zsh
```

### Daily use

```sh
dotfiles status
dotfiles add .claude/agents/reviewer.md
dotfiles commit -m "add reviewer agent"
dotfiles push
```

`.gitignore` is written to ignore first and allow only what is deliberately
tracked, so credentials and agent session state stay out even if you run
`dotfiles add -A`.

---

## 📄 License

This project is open source and available under the MIT License.
