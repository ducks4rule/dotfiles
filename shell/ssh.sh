# SSH key management.
# Override DOTFILES_SSH_KEYS in local.d/ssh.sh to specify keys explicitly.
if [ ${#DOTFILES_SSH_KEYS[@]} -eq 0 ]; then
    for _f in "$HOME"/.ssh/id_*; do
        [ -f "$_f" ] && [[ "$_f" != *.pub ]] && DOTFILES_SSH_KEYS+=("$_f")
    done
    unset _f
fi

if [ ${#DOTFILES_SSH_KEYS[@]} -gt 0 ]; then
    if command -v keychain >/dev/null 2>&1; then
        eval "$(keychain --eval --quiet "${DOTFILES_SSH_KEYS[@]}")"
    else
        eval "$(ssh-agent)" >/dev/null
    fi
fi
