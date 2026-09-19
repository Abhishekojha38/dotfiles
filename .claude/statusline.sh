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

# Human readable duration: 1h2m, 5m30s, or 45s.
fmt_duration() {
  awk -v ms="$1" 'BEGIN{
    s=int(ms/1000); h=int(s/3600); m=int((s%3600)/60); sec=s%60
    if (h>0) printf "%dh%dm", h, m
    else if (m>0) printf "%dm%ds", m, sec
    else printf "%ds", sec
  }'
}

# Time left until a rate limit window resets, from a unix timestamp.
fmt_until() {
  awk -v target="$1" -v now="$(date +%s)" 'BEGIN{
    s=target-now
    if (s<=0) { printf "now"; exit }
    h=int(s/3600); m=int((s%3600)/60)
    if (h>0) printf "%dh%dm", h, m
    else if (m>0) printf "%dm", m
    else printf "<1m"
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

# Session usage so far: spend, wall clock time, and lines changed.
COST_USD=$(echo "$input" | jq -r '.cost.total_cost_usd // empty')
DURATION_MS=$(echo "$input" | jq -r '.cost.total_duration_ms // empty')
LINES_ADDED=$(echo "$input" | jq -r '.cost.total_lines_added // 0')
LINES_REMOVED=$(echo "$input" | jq -r '.cost.total_lines_removed // 0')

USAGE_INFO=""
if [ -n "$COST_USD" ]; then
  USAGE_INFO=$(printf " | 💰 \$%.2f" "$COST_USD")
fi
if [ -n "$DURATION_MS" ]; then
  USAGE_INFO="$USAGE_INFO | ⏱ $(fmt_duration "$DURATION_MS")"
fi
if [ "$LINES_ADDED" -gt 0 ] || [ "$LINES_REMOVED" -gt 0 ]; then
  USAGE_INFO="$USAGE_INFO | 📝 +$LINES_ADDED/-$LINES_REMOVED"
fi

# Account rate limit windows, with time left on the 5 hour bucket.
FIVE_HOUR_PCT=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
FIVE_HOUR_RESET=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')
SEVEN_DAY_PCT=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')

LIMIT_INFO=""
if [ -n "$FIVE_HOUR_PCT" ]; then
  LIMIT_INFO=$(printf " | ⚡ 5h %.0f%%" "$FIVE_HOUR_PCT")
  if [ -n "$FIVE_HOUR_RESET" ]; then
    LIMIT_INFO="$LIMIT_INFO ($(fmt_until "$FIVE_HOUR_RESET"))"
  fi
fi
if [ -n "$SEVEN_DAY_PCT" ]; then
  LIMIT_INFO=$(printf "%s | 📅 7d %.0f%%" "$LIMIT_INFO" "$SEVEN_DAY_PCT")
fi

printf "\033[2m[%s] 📁 %s%s%s%s%s\033[0m" "$MODEL_NAME" "$DIR_NAME" "$GIT_BRANCH" "$TOKEN_INFO" "$USAGE_INFO" "$LIMIT_INFO"
