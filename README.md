# Dotfiles for Linux systems

## Installation

```bash
git clone <repo-url>
cd dotfiles
./install.sh
```

The installer:
- Moves the repo to `~/.dotfiles`
- Detects bash/zsh and symlinks `.bashrc`/`.zshrc` (backs up existing files to `.old`)
- Detects package manager (apt, dnf, pacman)
- Offers to install `bash-completion` and `zsh-autosuggestions`

Safe to run multiple times.

## Structure

```
~/.dotfiles/
    init.sh              # entry point — sources everything below
    install.sh           # installer
    shell/
        bashrc           # symlinked to ~/.bashrc
        zshrc            # symlinked to ~/.zshrc
        options.sh       # history, shell options
        prompt.sh        # colored prompt with git branch + venv
        completion.sh    # tab completion (bash + zsh)
        editor.sh        # EDITOR: nvim -> vim -> vi
        path.sh          # PATH additions
        plugins.sh       # zsh-autosuggestions
    aliases/
        general.sh       # navigation, git, ls, grep
    functions/
        utility.sh       # shell functions
    local.sh             # machine-specific config (gitignored)
```

## Machine-specific config

Create `~/.dotfiles/local.sh` for things that shouldn't be in the repo:
SSH keys, pyenv, tool-specific evals, custom PATHs, etc.

This file is sourced by `init.sh` but ignored by git.
