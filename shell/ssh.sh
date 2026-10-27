# SSH key management.
# Set DOTFILES_SSH_KEYS in local.d/ssh.sh, e.g.:
#   DOTFILES_SSH_KEYS=(~/.ssh/id_ed25519_git ~/.ssh/id_ed25519_work)
if [ ${#DOTFILES_SSH_KEYS[@]} -gt 0 ]; then
    if command -v keychain >/dev/null 2>&1; then
        eval "$(keychain --eval --quiet "${DOTFILES_SSH_KEYS[@]}")"
    else
        eval "$(ssh-agent)" >/dev/null
    fi
fi
