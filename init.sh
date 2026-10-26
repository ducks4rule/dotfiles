DOTFILES_DIR="$HOME/.dotfiles"
export DOTFILES_DIR

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

_source_dir "$DOTFILES_DIR/local.d"
