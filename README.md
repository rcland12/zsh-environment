# zsh-environment

zsh + Oh My Zsh + Powerlevel10k + plugins, and my dotfiles.

## New machine

```sh
git clone git@github.com:rcland12/zsh-environment.git ~/dev/zsh-environment
cd ~/dev/zsh-environment && ./install.sh     # --no-packages to skip apt/sudo
$EDITOR ~/.config/shell/secrets.sh           # add API keys
exec zsh
```

Dotfiles are **copied** into place as real files. To update a machine: `git pull && ./install.sh`.
Files that differ from the repo are moved to `~/.dotfiles-backup/<timestamp>/` before being
replaced, so nothing is lost. If you edit `~/.zshrc` directly on a machine, copy it back into
`home/` and commit, or the next install will replace it (backup kept).
Re-running `install.sh` is safe and also updates the plugins.

## Where things go

| What | File | In git? |
|---|---|---|
| Env vars for every shell (PATH, tool config) | `config/shell/env.sh` → `~/.config/shell/env.sh` | yes |
| Env vars for just this machine | `~/.config/shell/env.local.sh` | no |
| Secrets (API keys, tokens), chmod 600 | `~/.config/shell/secrets.sh` | **never** |
| Interactive zsh: aliases, prompt, plugins | `home/.zshrc` → `~/.zshrc` | yes |
| Interactive zsh for just this machine | `~/.zshrc.local` | no |
| Prompt config (`p10k configure`) | `home/.p10k.zsh` → `~/.p10k.zsh` | yes |

Load order: `~/.zshenv` (every zsh) and `~/.profile` (bash/sh/GUI login) both source
`env.sh`, which sources `env.local.sh` and then `secrets.sh`. `~/.zshrc` runs only in
interactive zsh and sources `~/.zshrc.local` at the end. Keep `env.sh` and its includes in
POSIX sh, quiet, and fast.

Prompt icons need a Nerd Font (MesloLGS NF) in the terminal you connect *from*.
