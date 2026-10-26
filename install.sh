#!/usr/bin/env bash
set -e

DOTFILES_TARGET="$HOME/.dotfiles"

detect_pkg_manager() {
    if command -v apt >/dev/null 2>&1; then echo "apt"
    elif command -v dnf >/dev/null 2>&1; then echo "dnf"
    elif command -v pacman >/dev/null 2>&1; then echo "pacman"
    fi
}

pkg_install() {
    case "$2" in
        apt)    sudo apt install -y "$1" ;;
        dnf)    sudo dnf install -y "$1" ;;
        pacman) sudo pacman -S --noconfirm "$1" ;;
        *)      echo "  Install '$1' manually."; return 1 ;;
    esac
}

backup_file() {
    if [ -f "$1" ] && [ ! -L "$1" ]; then
        echo "  Backing up $1 -> ${1}.old"
        mv "$1" "${1}.old"
    fi
}

link_file() {
    if [ -L "$2" ] && [ "$(readlink "$2")" = "$1" ]; then
        echo "  $2 already linked"
        return
    fi
    backup_file "$2"
    echo "  Linking $2 -> $1"
    ln -sf "$1" "$2"
}

echo "=== Dotfiles installer ==="

PKG_MANAGER="$(detect_pkg_manager)"
[ -n "$PKG_MANAGER" ] && echo "Package manager: $PKG_MANAGER"

SOURCE_DIR="$(cd "$(dirname "$0")" && pwd)"
if [ "$SOURCE_DIR" != "$DOTFILES_TARGET" ]; then
    if [ -d "$DOTFILES_TARGET" ]; then
        echo "Error: $DOTFILES_TARGET already exists. Remove it first."
        exit 1
    fi
    echo "Moving $SOURCE_DIR -> $DOTFILES_TARGET"
    mv "$SOURCE_DIR" "$DOTFILES_TARGET"
    exec "$DOTFILES_TARGET/install.sh"
fi

echo "Dotfiles: $DOTFILES_TARGET"

command -v bash >/dev/null 2>&1 && link_file "$DOTFILES_TARGET/shell/bashrc" "$HOME/.bashrc"
command -v zsh >/dev/null 2>&1 && link_file "$DOTFILES_TARGET/shell/zshrc" "$HOME/.zshrc"

if [ -n "$PKG_MANAGER" ]; then
    if command -v bash >/dev/null 2>&1; then
        if ! [ -f /usr/share/bash-completion/bash_completion ] && ! [ -f /etc/bash_completion ]; then
            read -r -p "Install bash-completion? [y/N] " reply
            [ "$reply" = "y" ] || [ "$reply" = "Y" ] && pkg_install bash-completion "$PKG_MANAGER"
        fi
    fi
    if command -v zsh >/dev/null 2>&1; then
        found=0
        for f in /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh \
                 /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh; do
            [ -f "$f" ] && found=1
        done
        if [ "$found" -eq 0 ]; then
            read -r -p "Install zsh-autosuggestions? [y/N] " reply
            [ "$reply" = "y" ] || [ "$reply" = "Y" ] && pkg_install zsh-autosuggestions "$PKG_MANAGER"
        fi
    fi
fi

echo ""
echo "Done. Restart your shell or run: source ~/.dotfiles/init.sh"
if [ ! -d "$DOTFILES_TARGET/local.d" ]; then
    echo "Tip: Create $DOTFILES_TARGET/local.d/ for machine-specific config (gitignored)."
fi
