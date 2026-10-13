# ~/.zshenv: read by EVERY zsh, interactive or not. Keep it cheap and quiet.

[ -f "$HOME/.config/shell/env.sh" ] && . "$HOME/.config/shell/env.sh"

typeset -U path PATH   # auto-dedupe PATH from here on
