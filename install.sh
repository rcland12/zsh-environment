#!/usr/bin/env bash
# zsh-environment installer: zsh + oh-my-zsh + powerlevel10k + plugins + dotfiles.
# Safe to re-run: existing files are backed up, repos are updated, nothing is duplicated.
#
#   ./install.sh                 full install
#   ./install.sh --no-packages   skip apt (no sudo needed)
#
# Dotfiles are copied into place as real files. After a `git pull`, re-run this to apply updates.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ZSH_DIR="$HOME/.oh-my-zsh"
ZSH_CUSTOM_DIR="$ZSH_DIR/custom"
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

INSTALL_PACKAGES=1
for arg in "$@"; do
  case "$arg" in
    --no-packages) INSTALL_PACKAGES=0 ;;
    -h|--help)     sed -n '2,8p' "$0"; exit 0 ;;
    *)             echo "Unknown option: $arg" >&2; exit 1 ;;
  esac
done

log()  { printf '\033[1;35m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m!!\033[0m %s\n' "$*" >&2; }

# ---- 1. Packages ----
install_packages() {
  local pkgs=(zsh git curl fzf eza zoxide)
  if command -v apt-get >/dev/null; then
    log "Installing packages via apt: ${pkgs[*]}"
    sudo apt-get update -qq
    sudo apt-get install -y -qq "${pkgs[@]}"
  elif command -v dnf >/dev/null; then
    log "Installing packages via dnf: ${pkgs[*]}"
    sudo dnf install -y "${pkgs[@]}"
  else
    warn "No apt-get/dnf found. Install these yourself: ${pkgs[*]}"
  fi
}

# ---- 2. Oh My Zsh, theme, plugins ----
clone_or_update() {  # <url> <dest>
  if [[ -d "$2/.git" ]]; then
    log "Updating $(basename "$2")"
    git -C "$2" pull --ff-only --quiet || warn "Could not update $2 (local changes?)"
  else
    log "Cloning $(basename "$2")"
    git clone --depth=1 --quiet "$1" "$2"
  fi
}

install_omz() {
  if [[ ! -d "$ZSH_DIR" ]]; then
    log "Installing Oh My Zsh"
    # Unattended, don't chsh, don't touch .zshrc - we manage it ourselves.
    # Pass ZSH explicitly: an inherited $ZSH (e.g. running from zsh) would misdirect it.
    ZSH="$ZSH_DIR" RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c \
      "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  else
    log "Oh My Zsh already installed"
  fi

  clone_or_update https://github.com/romkatv/powerlevel10k.git                     "$ZSH_CUSTOM_DIR/themes/powerlevel10k"
  clone_or_update https://github.com/zsh-users/zsh-autosuggestions.git             "$ZSH_CUSTOM_DIR/plugins/zsh-autosuggestions"
  clone_or_update https://github.com/zsh-users/zsh-syntax-highlighting.git         "$ZSH_CUSTOM_DIR/plugins/zsh-syntax-highlighting"
  clone_or_update https://github.com/zsh-users/zsh-history-substring-search.git    "$ZSH_CUSTOM_DIR/plugins/zsh-history-substring-search"
  clone_or_update https://github.com/Aloxaf/fzf-tab.git                            "$ZSH_CUSTOM_DIR/plugins/fzf-tab"
}

# ---- 3. Dotfiles ----
place() {  # <repo-relative src> <absolute dest>
  local src="$REPO_DIR/$1" dest="$2"
  mkdir -p "$(dirname "$dest")"

  # Already identical? Nothing to do.
  if [[ -f "$dest" && ! -L "$dest" ]] && cmp -s "$src" "$dest"; then
    return
  fi
  if [[ -e "$dest" || -L "$dest" ]]; then
    mkdir -p "$BACKUP_DIR/$(dirname "${dest#"$HOME"/}")"
    mv "$dest" "$BACKUP_DIR/${dest#"$HOME"/}"
    log "Backed up $dest"
  fi
  cp "$src" "$dest"
  log "Installed $dest"
}

install_dotfiles() {
  place home/.zshenv          "$HOME/.zshenv"
  place home/.zshrc           "$HOME/.zshrc"
  place home/.profile         "$HOME/.profile"
  place home/.p10k.zsh        "$HOME/.p10k.zsh"
  place config/shell/env.sh   "$HOME/.config/shell/env.sh"

  # Machine-local files: created from templates once, never overwritten, never tracked.
  local secrets="$HOME/.config/shell/secrets.sh"
  if [[ ! -f "$secrets" ]]; then
    install -m 600 "$REPO_DIR/config/shell/secrets.sh.example" "$secrets"
    log "Created $secrets from template - fill in your values"
  fi
  chmod 600 "$secrets"

  local envlocal="$HOME/.config/shell/env.local.sh"
  [[ -f "$envlocal" ]] || { cp "$REPO_DIR/config/shell/env.local.sh.example" "$envlocal"; log "Created $envlocal"; }

  [[ -f "$HOME/.zshrc.local" ]] || { cp "$REPO_DIR/home/.zshrc.local.example" "$HOME/.zshrc.local"; log "Created ~/.zshrc.local"; }
}

# ---- 4. Default shell ----
set_default_shell() {
  local zsh_path
  zsh_path="$(command -v zsh || true)"
  if [[ -z "$zsh_path" ]]; then
    warn "zsh not found - skipping chsh"
  elif [[ "$(getent passwd "$USER" | cut -d: -f7)" != "$zsh_path" ]]; then
    log "Changing default shell to $zsh_path"
    chsh -s "$zsh_path" || warn "chsh failed - run: chsh -s $zsh_path"
  fi
}

(( INSTALL_PACKAGES )) && install_packages
command -v git >/dev/null || { warn "git is required"; exit 1; }
command -v zsh >/dev/null || warn "zsh is not installed - re-run without --no-packages or install it"
install_omz
install_dotfiles
(( INSTALL_PACKAGES )) && set_default_shell

log "Done. Start a new shell with: exec zsh"
[[ -d "$BACKUP_DIR" ]] && log "Previous files saved in $BACKUP_DIR"
log "Prompt icons need a Nerd Font (e.g. MesloLGS NF) in your *local* terminal, not on the server."
