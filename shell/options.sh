HISTLEN=10000

if [ -n "$BASH_VERSION" ]; then
    HISTSIZE=$HISTLEN
    HISTFILESIZE=$HISTLEN
    HISTCONTROL=ignoredups
    shopt -s histappend
elif [ -n "$ZSH_VERSION" ]; then
    HISTSIZE=$HISTLEN
    SAVEHIST=$HISTLEN
    setopt HIST_IGNORE_DUPS
    setopt appendhistory
fi
