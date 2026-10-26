# Colorized output
alias ls='ls --color=auto'
alias grep='grep --color=auto'

# Navigation
alias ..="cd .."
alias ...="cd ../.."
alias gh="cd ~"

# List files
alias ll="ls -lah"
alias la="ls -A"

# Git: status & log
alias gs="git status"
alias gl="git log --oneline -15"
alias gd="git diff --stat"
alias gds="git diff --staged"
alias gitlog='git log --all --graph --oneline --format="%C(yellow)%h %C(bold blue)%an %C(green)%ad %C(yellow)%d %C(reset)%s" --date=relative'
alias gittag='git tag --sort=-creatordate --format="%(color:yellow)%(refname:short)%(color:reset) - %(color:green)%(creatordate:short)%(color:reset) - %(color:bold blue)%(taggername)%(color:reset) - %(contents:subject)"'

# Git: staging & committing
alias ga='git add'
alias gc='git commit -m'
alias gca='git commit --amend --no-edit'

# Git: branching
alias gb='git branch'
alias gco='git checkout'

# Git: push & pull
alias gp='git push'
alias gpl='git pull'

# Git: undo
alias gundo='git reset --soft HEAD~1'
