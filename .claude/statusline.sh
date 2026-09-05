#!/bin/bash

input=$(cat)

MODEL_NAME=$(echo "$input" | jq -r '.model.display_name')
CURRENT_DIR=$(echo "$input" | jq -r '.workspace.current_dir')
DIR_NAME=$(basename "$CURRENT_DIR")

GIT_BRANCH=""
if git --git-dir="$CURRENT_DIR/.git" rev-parse --is-inside-work-tree >/dev/null 2>&1 || git -C "$CURRENT_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  BRANCH=$(git -C "$CURRENT_DIR" --no-optional-locks branch --show-current 2>/dev/null)
  if [ -n "$BRANCH" ]; then
    GIT_BRANCH=" | 🌿 $BRANCH"
  fi
fi

TOKENS_IN=$(echo "$input" | jq -r '.context_window.total_input_tokens // 0')
WINDOW_SIZE=$(echo "$input" | jq -r '.context_window.context_window_size // 0')
USED_PCT=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

fmt_tokens() {
  awk -v n="$1" 'BEGIN{
    if (n>=1000000) { v=n/1000000; u="m" }
    else if (n>=1000) { v=n/1000; u="k" }
    else { printf "%d", n; exit }
    if (v==int(v)) printf "%d%s", v, u; else printf "%.1f%s", v, u
  }'
}

TOKEN_INFO=""
if [ "$WINDOW_SIZE" -gt 0 ]; then
  TOKENS_IN_FMT=$(fmt_tokens "$TOKENS_IN")
  WINDOW_SIZE_FMT=$(fmt_tokens "$WINDOW_SIZE")
  if [ -n "$USED_PCT" ]; then
    TOKEN_INFO=$(printf " | 🔢 %s/%s tokens (%.0f%%)" "$TOKENS_IN_FMT" "$WINDOW_SIZE_FMT" "$USED_PCT")
  else
    TOKEN_INFO=$(printf " | 🔢 %s/%s tokens" "$TOKENS_IN_FMT" "$WINDOW_SIZE_FMT")
  fi
fi

printf "\033[2m[%s] 📁 %s%s%s\033[0m" "$MODEL_NAME" "$DIR_NAME" "$GIT_BRANCH" "$TOKEN_INFO"
