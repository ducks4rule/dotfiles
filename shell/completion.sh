if [ -n "$BASH_VERSION" ]; then
    if [ -f /usr/share/bash-completion/bash_completion ]; then
        source /usr/share/bash-completion/bash_completion
    elif [ -f /etc/bash_completion ]; then
        source /etc/bash_completion
    fi
elif [ -n "$ZSH_VERSION" ]; then
    autoload -Uz compinit
    compinit
fi
