# Add ~/.local/bin if it exists and isn't already in PATH
# (pipx, pip --user, and other tools install here)
case ":$PATH:" in
    *":$HOME/.local/bin:"*) ;;
    *) export PATH="$HOME/.local/bin:$PATH" ;;
esac
