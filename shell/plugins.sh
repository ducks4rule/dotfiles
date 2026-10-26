# zsh-autosuggestions — install path varies by distro
if [ -n "$ZSH_VERSION" ]; then
    for f in \
        /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh \
        /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh; do
        if [ -f "$f" ]; then
            source "$f"
            break
        fi
    done
fi
