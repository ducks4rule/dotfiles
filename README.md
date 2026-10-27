# Dotfiles for Linux systems

## Installation

```bash
git clone <repo-url>
cd dotfiles
./install.sh
```

Moves repo to `~/.dotfiles`, detects bash/zsh, symlinks rc files (backs up existing to `.old`),
detects package manager (apt/dnf/pacman), offers to install bash-completion and zsh-autosuggestions.
Safe to run multiple times.

## Uninstall

```bash
~/.dotfiles/uninstall.sh
```

Removes symlinks and restores `.old` backups. Does not delete `~/.dotfiles`.

## Structure

```
~/.dotfiles/
    init.sh           # sources everything below
    install.sh
    shell/
        bashrc        # -> ~/.bashrc
        zshrc         # -> ~/.zshrc
        options.sh    # history, shell options
        prompt.sh     # colored prompt: git branch + venv + path truncation
        completion.sh # tab completion
        editor.sh     # EDITOR: nvim -> vim -> vi
        path.sh       # PATH additions
        plugins.sh    # zsh-autosuggestions
    aliases/
        general.sh    # navigation, git, ls, grep
    functions/
        utility.sh
    local.d/          # machine-specific (gitignored)
```

## local.d

Put `.sh` files in `~/.dotfiles/local.d/` for machine-specific config (SSH keys, pyenv, etc.).
Sourced automatically, gitignored. Can be its own private repo.
