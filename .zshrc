# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export PATH="$HOME/.local/bin:$PATH"

source_first_available() {
  local candidate
  for candidate in "$@"; do
    if [[ -r "$candidate" ]]; then
      source "$candidate"
      return
    fi
  done
}

if command -v brew >/dev/null 2>&1; then
  BREW_PREFIX="$(brew --prefix)"
else
  BREW_PREFIX=""
fi

source_first_available \
  "${XDG_DATA_HOME:-$HOME/.local/share}/powerlevel10k/powerlevel10k.zsh-theme" \
  "${BREW_PREFIX:+$BREW_PREFIX/share/powerlevel10k/powerlevel10k.zsh-theme}"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
source_first_available \
  "${BREW_PREFIX:+$BREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh}" \
  /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# history setup
HISTFILE=$HOME/.zhistory
SAVEHIST=1000
HISTSIZE=999
setopt share_history
setopt hist_expire_dups_first
setopt hist_ignore_dups
setopt hist_verify

# completion using arrow keys (based on history)
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward

# ---- Eza (better ls) -----

if command -v eza >/dev/null 2>&1; then
  alias ls="eza --icons=always"
fi

# ---- Zoxide (better cd) ----
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
  alias cd="z"
fi

# ---- FZF -----

# Set up fzf key bindings and fuzzy completion
if command -v fzf >/dev/null 2>&1; then
  if FZF_ZSH_INIT="$(fzf --zsh 2>/dev/null)"; then
    eval "$FZF_ZSH_INIT"
  else
    source_first_available /usr/share/doc/fzf/examples/key-bindings.zsh
    source_first_available /usr/share/doc/fzf/examples/completion.zsh
  fi
  unset FZF_ZSH_INIT
fi

source_first_available \
  "${BREW_PREFIX:+$BREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh}" \
  /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

unset BREW_PREFIX
unfunction source_first_available

# ---- Dotfiles (bare repo, work tree is $HOME) ----
# Manage tracked config from anywhere, e.g. `dotfiles status`, `dotfiles add`.
alias dotfiles='git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
