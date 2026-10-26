DOTFILES_DIR="$HOME/.dotfiles"
export DOTFILES_DIR

# Source all .sh files in a given directory.
# Usage: _source_dir /path/to/directory
_source_dir() {
    local dir="$1"
    if [ -d "$dir" ]; then
        for f in "$dir"/*.sh; do
            [ -f "$f" ] && source "$f"
        done
    fi
}

_source_dir "$DOTFILES_DIR/shell"
_source_dir "$DOTFILES_DIR/aliases"
_source_dir "$DOTFILES_DIR/functions"

# Machine-specific config (gitignored — create this file for SSH keys, pyenv, etc.)
[ -f "$DOTFILES_DIR/local.sh" ] && source "$DOTFILES_DIR/local.sh"
