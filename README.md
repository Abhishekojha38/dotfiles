# dotfiles

Personal configuration files for terminal tools.

## Contents

- `.tmux.conf` — tmux configuration
- `.config/wezterm/wezterm.lua` — WezTerm terminal emulator configuration

## tmux shortcuts

Prefix key is remapped to `Ctrl-a`.

| Shortcut | Action |
| --- | --- |
| `tmux new -s <name>` | Create a new named session |
| `tmux attach -t <name>` | Attach to a session |
| `tmux kill-session -t <name>` | Kill a session |
| `Ctrl-a` | Prefix key |
| `Prefix + \|` | Split pane vertically |
| `Prefix + -` | Split pane horizontally |
| `Prefix + ←` | Move to pane on the left |
| `Prefix + ↓` | Move to pane below |
| `Prefix + ↑` | Move to pane above |
| `Prefix + →` | Move to pane on the right |
| `Prefix + r` | Reload tmux config |
| `Prefix + c` | Create new window |
| `Prefix + d` | Detach from session |
| `Prefix + x` | Kill current pane |
| `Prefix + k` | Kill current window |
| Mouse | Resize/select panes, scroll |

## Usage

Clone this repository and symlink the files into your home directory:

```sh
cp "$(pwd)/.tmux.conf" ~/.tmux.conf
cp -r "$(pwd)/.config/wezterm" ~/.config/wezterm
```
