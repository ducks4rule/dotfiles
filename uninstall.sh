#!/usr/bin/env bash
set -e

DOTFILES_TARGET="$HOME/.dotfiles"

restore_file() {
    local file="$1"
    if [ -L "$file" ]; then
        rm "$file"
        echo "  Removed symlink $file"
        if [ -f "${file}.old" ]; then
            mv "${file}.old" "$file"
            echo "  Restored ${file}.old -> $file"
        fi
    fi
}

echo "=== Dotfiles uninstaller ==="

restore_file "$HOME/.bashrc"
restore_file "$HOME/.zshrc"

echo ""
echo "Done. $DOTFILES_TARGET was NOT removed."
echo "Delete it manually if you want: rm -rf $DOTFILES_TARGET"
