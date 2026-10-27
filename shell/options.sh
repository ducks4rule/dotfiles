HISTLEN=10000

if [ -n "$BASH_VERSION" ]; then
    HISTSIZE=$HISTLEN
    HISTFILESIZE=$HISTLEN
    HISTCONTROL=ignoredups
    shopt -s histappend
    # Up/Down arrow: search history by prefix already typed
    bind '"\e[A": history-search-backward'
    bind '"\e[B": history-search-forward'
elif [ -n "$ZSH_VERSION" ]; then
    HISTFILE="${HISTFILE:-$HOME/.zsh_history}"
    HISTSIZE=$HISTLEN
    SAVEHIST=$HISTLEN
    setopt HIST_IGNORE_DUPS
    setopt SHARE_HISTORY
    bindkey -e
    # Up/Down arrow: search history by prefix already typed
    autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
    zle -N up-line-or-beginning-search
    zle -N down-line-or-beginning-search
    bindkey '^[[A' up-line-or-beginning-search
    bindkey '^[[B' down-line-or-beginning-search
fi
