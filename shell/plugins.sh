if [ -n "$ZSH_VERSION" ]; then
    WORDCHARS="${WORDCHARS//\//}"

    for f in \
        /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh \
        /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh; do
        if [ -f "$f" ]; then
            source "$f"
            bindkey '\ee' autosuggest-accept   # Alt+e: accept full suggestion
            bindkey '\e;' forward-word          # Alt+;: accept next segment
            break
        fi
    done
fi
