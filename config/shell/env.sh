# ~/.config/shell/env.sh
# Shared environment for every shell. POSIX sh only - no zsh/bash syntax.
# Sourced by ~/.zshenv (zsh) and ~/.profile (sh/bash + graphical session).

# TLS: point tools at the system CA bundle (needed behind an inspecting proxy)
export REQUESTS_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt
export CURL_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt
export NODE_EXTRA_CA_CERTS=/etc/ssl/certs/ca-certificates.crt
export SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt

# GPG pinentry
export PINENTRY_USER_DATA="USE_CURSES=1"

# Tools
export CLAUDE_CONFIG_DIR="$HOME/.config/claude-code"
export PNPM_HOME="$HOME/.local/share/pnpm"

HOST_UID=$(id -u); export HOST_UID
HOST_GID=$(id -g); export HOST_GID

# PATH - idempotent, so re-sourcing never duplicates entries
for _dir in "$HOME/.bin" "$HOME/bin" "$HOME/.local/bin" "$PNPM_HOME" "$HOME/.opencode/bin"; do
    case ":$PATH:" in
        *":$_dir:"*) ;;
        *) [ -d "$_dir" ] && PATH="$_dir:$PATH" ;;
    esac
done
unset _dir
export PATH

# Machine-specific, untracked: non-secret overrides, then secrets (chmod 600)
[ -f "$HOME/.config/shell/env.local.sh" ] && . "$HOME/.config/shell/env.local.sh"
[ -f "$HOME/.config/shell/secrets.sh" ] && . "$HOME/.config/shell/secrets.sh"
