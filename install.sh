#!/usr/bin/env bash
set -e

DOTFILES_TARGET="$HOME/.dotfiles"

# --- Detect package manager ---
detect_pkg_manager() {
    if command -v apt >/dev/null 2>&1; then
        echo "apt"
    elif command -v dnf >/dev/null 2>&1; then
        echo "dnf"
    elif command -v pacman >/dev/null 2>&1; then
        echo "pacman"
    else
        echo ""
    fi
}

# --- Install a package if not already installed ---
pkg_install() {
    local pkg="$1"
    local mgr="$2"
    case "$mgr" in
        apt)    sudo apt install -y "$pkg" ;;
        dnf)    sudo dnf install -y "$pkg" ;;
        pacman) sudo pacman -S --noconfirm "$pkg" ;;
        *)      echo "  No supported package manager found. Install '$pkg' manually."; return 1 ;;
    esac
}

# --- Backup a file (only if it's a real file, not a symlink) ---
backup_file() {
    local file="$1"
    if [ -f "$file" ] && [ ! -L "$file" ]; then
        local backup="${file}.old"
        echo "  Backing up $file -> $backup"
        mv "$file" "$backup"
    fi
}

# --- Create symlink ---
link_file() {
    local src="$1"
    local dst="$2"

    if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
        echo "  $dst already linked (skipping)"
        return
    fi

    backup_file "$dst"
    echo "  Linking $dst -> $src"
    ln -sf "$src" "$dst"
}

# --- Main ---
echo "=== Dotfiles installer ==="
echo ""

PKG_MANAGER="$(detect_pkg_manager)"
if [ -n "$PKG_MANAGER" ]; then
    echo "Package manager: $PKG_MANAGER"
else
    echo "Warning: no supported package manager found (apt, dnf, pacman)"
fi

# Move repo to ~/.dotfiles if not already there
SOURCE_DIR="$(cd "$(dirname "$0")" && pwd)"
if [ "$SOURCE_DIR" != "$DOTFILES_TARGET" ]; then
    if [ -d "$DOTFILES_TARGET" ]; then
        echo ""
        echo "Error: $DOTFILES_TARGET already exists."
        echo "Remove it first if you want to reinstall."
        exit 1
    fi
    echo ""
    echo "Moving $SOURCE_DIR -> $DOTFILES_TARGET"
    mv "$SOURCE_DIR" "$DOTFILES_TARGET"
    echo "Re-running from new location..."
    exec "$DOTFILES_TARGET/install.sh"
fi

echo ""
echo "Dotfiles directory: $DOTFILES_TARGET"

# Detect installed shells and link rc files
echo ""
echo "--- Shell config ---"
if command -v bash >/dev/null 2>&1; then
    link_file "$DOTFILES_TARGET/shell/bashrc" "$HOME/.bashrc"
fi
if command -v zsh >/dev/null 2>&1; then
    link_file "$DOTFILES_TARGET/shell/zshrc" "$HOME/.zshrc"
fi

# Offer to install useful packages
echo ""
echo "--- Packages ---"
if [ -n "$PKG_MANAGER" ]; then
    if command -v bash >/dev/null 2>&1; then
        if ! [ -f /usr/share/bash-completion/bash_completion ] && ! [ -f /etc/bash_completion ]; then
            read -r -p "Install bash-completion? [y/N] " reply
            if [ "$reply" = "y" ] || [ "$reply" = "Y" ]; then
                pkg_install bash-completion "$PKG_MANAGER"
            fi
        else
            echo "  bash-completion: already installed"
        fi
    fi

    if command -v zsh >/dev/null 2>&1; then
        local_found=0
        for f in \
            /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh \
            /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh; do
            [ -f "$f" ] && local_found=1
        done
        if [ "$local_found" -eq 0 ]; then
            read -r -p "Install zsh-autosuggestions? [y/N] " reply
            if [ "$reply" = "y" ] || [ "$reply" = "Y" ]; then
                pkg_install zsh-autosuggestions "$PKG_MANAGER"
            fi
        else
            echo "  zsh-autosuggestions: already installed"
        fi
    fi
else
    echo "  Skipping (no package manager detected)"
fi

# Summary
echo ""
echo "--- Done ---"
echo "Restart your shell or run: source ~/.dotfiles/init.sh"
echo ""
if [ ! -f "$DOTFILES_TARGET/local.sh" ]; then
    echo "Tip: Create $DOTFILES_TARGET/local.sh for machine-specific config"
    echo "     (SSH keys, pyenv, custom PATHs, etc.) — this file is gitignored."
fi
