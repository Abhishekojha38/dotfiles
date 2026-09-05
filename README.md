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
git clone --bare https://github.com/Abhishekojha38/dotfiles.git "$HOME/.cfg"
```

**2. Define the `config` alias for this shell.**

```sh
alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
```

**3. Check the files out into `$HOME`.**

Anything already in the way is moved to `~/.cfg-backup/` first, keeping its
original sub-path, so nothing is lost and the checkout can succeed.

```sh
config checkout 2>&1 | awk '/^\t/ { sub(/^\t/, ""); print }' | while read -r f; do
  mkdir -p "$HOME/.cfg-backup/$(dirname "$f")"
  mv "$HOME/$f" "$HOME/.cfg-backup/$f"
done

config checkout
```

**4. Stop `config status` from listing your entire home directory.**

```sh
config config --local status.showUntrackedFiles no
```

**5. Install the packages and set the login shell.**

```sh
chmod +x "$HOME/install.sh" && "$HOME/install.sh"
```

**6. Restart the shell.**

`.zshrc` defines the `config` alias permanently, so it is available from now
on.

```sh
exec zsh
```

### All steps at once

```sh
git clone --bare https://github.com/Abhishekojha38/dotfiles.git "$HOME/.cfg"
alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'

config checkout 2>&1 | awk '/^\t/ { sub(/^\t/, ""); print }' | while read -r f; do
  mkdir -p "$HOME/.cfg-backup/$(dirname "$f")"
  mv "$HOME/$f" "$HOME/.cfg-backup/$f"
done

config checkout
config config --local status.showUntrackedFiles no
chmod +x "$HOME/install.sh" && "$HOME/install.sh"
exec zsh
```

### Starting from scratch instead

If you are creating the repository rather than cloning it:

```sh
git init --bare "$HOME/.cfg"
alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
config config --local status.showUntrackedFiles no
config add .zshrc
config commit -m "add zsh profile"
config remote add origin git@github.com:Abhishekojha38/dotfiles.git
config push -u origin main
```

### Daily use

```sh
config status
config add .claude/agents/reviewer.md
config commit -m "add reviewer agent"
config push
```

Stage files explicitly, one path at a time.
`config add -A` in a home directory work tree would sweep in anything
untracked that sits there, so `.gitignore` stays short and the discipline
does the work.

## 🤖 Agent Configuration

These dotfiles carry global configuration for two AI coding agents, Claude
Code and GitHub Copilot CLI.
`AGENTS.md` checks out to `~/AGENTS.md` and is the single canonical
instruction file.
`.claude/CLAUDE.md` and `.copilot/copilot-instructions.md` are relative
symlinks to it, committed in the repository, so a checkout gives both tools
the same file without any install step.

### Instruction files

Which markdown file is read by which tool, and at which scope.
"Canary" means the path was proven by writing a unique token into the file
and making the tool echo it back, not read off documentation.

| File | Scope | Claude Code | Copilot CLI | Evidence |
| ---- | ----- | ----------- | ----------- | -------- |
| `~/.claude/CLAUDE.md` | Global | ✅ reads | ❌ | Canary |
| `~/.copilot/copilot-instructions.md` | Global | ❌ | ✅ reads | Canary |
| `~/.copilot/instructions/*.instructions.md` | Global | ❌ | ✅ reads | Canary |
| `AGENTS.md` (repo root) | Project | ✅ reads | ✅ reads | Canary, both |
| `CLAUDE.md` (repo root) | Project | ✅ reads | ✅ reads | Canary for Copilot; documented for Claude |
| `.claude/CLAUDE.md` | Project | ✅ reads | ✅ reads | Canary for Claude; Copilot help only |
| `.github/copilot-instructions.md` | Project | ❌ | ✅ reads | Canary |
| `.github/instructions/*.instructions.md` | Project | ❌ | ✅ reads | Canary |

### Directories

| Path | Scope | Tool | Holds |
| ---- | ----- | ---- | ----- |
| `~/.claude/agents/` | Global | Claude | Subagents, one `*.md` each |
| `~/.claude/commands/` | Global | Claude | Slash commands, one `*.md` each |
| `~/.claude/skills/` | Global | Claude | Skills, a dir per skill with `SKILL.md` |
| `~/.claude/settings.json` | Global | Claude | Model, theme, statusline, permissions |
| `~/.claude/statusline.sh` | Global | Claude | Script referenced by `settings.json` |
| `~/.copilot/agents/` | Global | Copilot | Custom agents, one `*.agent.md` each |
| `~/.copilot/skills/` | Global | Copilot | Skills, a dir per skill with `SKILL.md` |
| `.claude/{agents,commands,skills}/` | Project | Claude | Same, scoped to one repository |
| `.github/{agents,skills}/` | Project | Copilot | Same, scoped to one repository |

Every Global row above is a tracked file in this repository, checked out
directly to that path.
Project rows are per-repository and are not managed here.

### Supported combinations

Pick the file by which tools should see it and how widely it should apply.

| Goal | File to use |
| ---- | ----------- |
| Both tools, every project | `~/AGENTS.md`, which both tools reach by symlink |
| Both tools, one project | `AGENTS.md` at that repository's root |
| Claude only, every project | `~/.claude/CLAUDE.md`, unlinked from the shared file first |
| Claude only, one project | `.claude/CLAUDE.md` in that repository |
| Copilot only, every project | `~/.copilot/copilot-instructions.md`, unlinked first |
| Copilot only, one project | `.github/copilot-instructions.md` |
| Copilot, only for certain files | `.github/instructions/*.instructions.md` with an `applyTo` glob |

The first row is what this repository is set up to do.
Because one canonical `AGENTS.md` feeds both global paths, splitting the
tools apart means replacing a committed symlink with a real file, which is
why the Claude-only and Copilot-only global rows say "unlinked first".

### Repository layout

Every path is where it lands in `$HOME` after checkout.

```
~/AGENTS.md                          canonical instructions, one source
~/.claude/
  CLAUDE.md            -> ../AGENTS.md   (committed symlink)
  settings.json                      model, theme, statusline
  statusline.sh                      referenced by settings.json
  agents/  commands/  skills/
~/.copilot/
  copilot-instructions.md -> ../AGENTS.md   (committed symlink)
  agents/  skills/  instructions/
~/.config/                           nvim, wezterm, herdr
~/.zshrc  ~/.tmux.conf  ~/install.sh
```

Both tools also write session state, logs and credentials into `~/.claude`
and `~/.copilot`.
`.gitignore` excludes those directories wholesale and re-includes only the
files listed above, so runtime state and tokens are never tracked.

### Copilot in VS Code

VS Code is a third surface with its own rules.
It does not read the personal `~/.copilot/copilot-instructions.md`, but it
does read the `~/.copilot/instructions/` directory that this repository
already tracks, via the `chat.instructionsFilesLocations` setting.

| File | VS Code | Copilot CLI | Evidence |
| ---- | ------- | ----------- | -------- |
| `~/.copilot/instructions/*.instructions.md` | ✅ reads | ✅ reads | Docs for VS Code; canary for CLI |
| `~/.claude/rules/*.instructions.md` | ✅ reads | ❌ | Docs only |
| `~/.copilot/copilot-instructions.md` | ❌ | ✅ reads | Docs for VS Code; canary for CLI |
| `.github/copilot-instructions.md` | ✅ reads | ✅ reads | Docs for VS Code; canary for CLI |
| `AGENTS.md` (repo root) | ✅ reads | ✅ reads | Docs for VS Code; canary for CLI |
| `AGENTS.md` (user level) | ❌ not supported | n/a | Docs only |

None of the VS Code rows are canary-verified, because the Copilot extension
is not installed in this machine's VS Code.
Treat them as documentation until tested the way the other tables were.

The practical gap is that the canonical `AGENTS.md` reaches VS Code in a
project but not globally, since user-level `AGENTS.md` is not a supported
concept there.
Covering VS Code globally means adding an `*.instructions.md` file with an
`applyTo: "**"` header under `.copilot/instructions/`.

## 📄 License

This project is open source and available under the MIT License.
