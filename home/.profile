# ~/.profile: read by sh/bash login shells, and by the graphical session at login.
# zsh does NOT read this file - see ~/.zshenv.

# if running bash, include .bashrc
if [ -n "$BASH_VERSION" ] && [ -f "$HOME/.bashrc" ]; then
    . "$HOME/.bashrc"
fi

[ -f "$HOME/.config/shell/env.sh" ] && . "$HOME/.config/shell/env.sh"
