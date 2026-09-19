#!/usr/bin/env bash
#
# Deploys configuration from a regular clone into the current user's home.
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="${HOME}/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
BACKED_UP=false

deploy_path() {
  local relative_path="$1"
  local source_path="$DOTFILES_DIR/$relative_path"
  local target_path="$HOME/$relative_path"
  local backup_path="$BACKUP_DIR/$relative_path"

  if [[ -e "$target_path" || -L "$target_path" ]]; then
    if diff -qr "$source_path" "$target_path" >/dev/null 2>&1; then
      return
    fi

    mkdir -p "$(dirname "$backup_path")"
    mv "$target_path" "$backup_path"
    BACKED_UP=true
  fi

  mkdir -p "$(dirname "$target_path")"
  cp -a "$source_path" "$target_path"
  printf 'Deployed %s\n' "$relative_path"
}

deploy_path AGENTS.md
deploy_path .zshrc
deploy_path .tmux.conf
deploy_path .config/nvim
deploy_path .config/wezterm
deploy_path .config/herdr/config.toml
deploy_path .claude/CLAUDE.md
deploy_path .claude/settings.json
deploy_path .claude/statusline.sh
deploy_path .copilot/copilot-instructions.md

mkdir -p \
  "$HOME/.claude/agents" \
  "$HOME/.claude/commands" \
  "$HOME/.claude/skills" \
  "$HOME/.copilot/agents" \
  "$HOME/.copilot/instructions" \
  "$HOME/.copilot/skills"

if [[ "$BACKED_UP" == true ]]; then
  printf 'Previous files were backed up to %s\n' "$BACKUP_DIR"
fi
