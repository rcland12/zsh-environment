# ---- Powerlevel10k instant prompt. Must stay near the top. ----
# Anything that prints output or needs console input must go ABOVE this block.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ---- Oh My Zsh ----
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

plugins=(
  git
  sudo
  docker
  docker-compose
  command-not-found
  colored-man-pages
  extract
  zsh-autosuggestions
  fzf-tab
  zsh-syntax-highlighting
  zsh-history-substring-search
)

source $ZSH/oh-my-zsh.sh

# ---- Prompt ----
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
[[ ! -f ~/.p10k.synthwave.zsh ]] || source ~/.p10k.synthwave.zsh

# ---- GPG signing ----
# $TTY is set by zsh and survives p10k's instant-prompt stdin redirection.
# $(tty) does NOT - it returns the literal string "not a tty" here.
export GPG_TTY=$TTY
gpg-connect-agent updatestartuptty /bye >/dev/null 2>&1

# ---- Synthwave syntax highlighting ----
typeset -gA ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[command]='fg=#fc199a,bold'
ZSH_HIGHLIGHT_STYLES[builtin]='fg=#fc199a'
ZSH_HIGHLIGHT_STYLES[reserved-word]='fg=#9963ff,italic'
ZSH_HIGHLIGHT_STYLES[function]='fg=#61e2ff'
ZSH_HIGHLIGHT_STYLES[alias]='fg=#61e2ff'
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=#ffcc00'
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=#ffcc00'
ZSH_HIGHLIGHT_STYLES[path]='fg=#03edf9,underline'
ZSH_HIGHLIGHT_STYLES[globbing]='fg=#9963ff'
ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=#ff5577,bold'

ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#5a3c7a'

HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND='bg=#34104d,fg=#03edf9,bold'
HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_NOT_FOUND='bg=#3a0b2e,fg=#fc199a'
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

export FZF_DEFAULT_OPTS="
  --color=fg:#c8b6e2,bg:-1,hl:#fc199a
  --color=fg+:#ffffff,bg+:#34104d,hl+:#03edf9
  --color=info:#9963ff,prompt:#fc28a8,pointer:#03edf9
  --color=marker:#ffcc00,spinner:#b14de0,header:#61e2ff,border:#9963ff"

export LESS_TERMCAP_md=$'\e[38;2;252;25;154m'
export LESS_TERMCAP_us=$'\e[38;2;3;237;249m'
export LESS_TERMCAP_so=$'\e[48;2;52;16;77m\e[38;2;255;204;0m'
export LESS_TERMCAP_me=$'\e[0m'
export LESS_TERMCAP_se=$'\e[0m'
export LESS_TERMCAP_ue=$'\e[0m'

export EZA_COLORS="di=38;2;153;99;255:ex=38;2;252;25;154:ln=38;2;3;237;249:fi=38;2;200;182;226:da=38;2;97;226;255"

# ---- Aliases & functions ----
if (( $+commands[eza] )); then
  alias ls='eza --group-directories-first'
  alias ll='eza -lah --group-directories-first --git'
fi

clearpycache() {
    local target_dir="${1:-.}"
    echo "Cleaning __pycache__ in: $target_dir"
    find "$target_dir" -type d -name "__pycache__" -exec rm -rf {} +
    echo "Pycache cleared."
}

# ---- Version managers / tooling ----
(( $+commands[zoxide] )) && eval "$(zoxide init zsh)"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

[ -f "$HOME/.deno/env" ] && . "$HOME/.deno/env"
if (( $+commands[deno] )); then
  source <(deno completions zsh)
fi

if [[ -d "$HOME/miniforge3" ]]; then
# >>> conda initialize >>>
__conda_setup="$("$HOME/miniforge3/bin/conda" 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "$HOME/miniforge3/etc/profile.d/conda.sh" ]; then
        . "$HOME/miniforge3/etc/profile.d/conda.sh"
    else
        export PATH="$HOME/miniforge3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <

# >>> mamba initialize >>>
export MAMBA_EXE="$HOME/miniforge3/bin/mamba"
export MAMBA_ROOT_PREFIX="$HOME/miniforge3"
__mamba_setup="$("$MAMBA_EXE" shell hook --shell zsh --root-prefix "$MAMBA_ROOT_PREFIX" 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__mamba_setup"
else
    alias mamba="$MAMBA_EXE"
fi
unset __mamba_setup
# <<< mamba initialize <
fi

# ---- Machine-local overrides (not tracked in zsh-environment repo) ----
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
