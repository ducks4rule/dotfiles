if [ -n "$ZSH_VERSION" ]; then
    for f in \
        /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh \
        /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh; do
        if [ -f "$f" ]; then
            source "$f"
            _forward_segment() {
                local rest="${BUFFER#$LBUFFER}"
                if [[ "$rest" =~ ^[^[:space:]/]*[[:space:]/] ]]; then
                    CURSOR=$(( CURSOR + ${#MATCH} ))
                else
                    CURSOR=$(( CURSOR + ${#rest} ))
                fi
            }
            zle -N _forward_segment
            ZSH_AUTOSUGGEST_PARTIAL_ACCEPT_WIDGETS+=(_forward_segment)
            bindkey '\ee' autosuggest-accept   # Alt+e: accept full suggestion
            bindkey '\e;' _forward_segment     # Alt+;: accept next segment
            break
        fi
    done
fi
