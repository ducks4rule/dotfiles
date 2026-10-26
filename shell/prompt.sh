# Prompt: (venv) u@host:~/p/myapp (main) $
# Colors: none=venv, dark green=user (red if root), cyan=path, dark blue=git

PROMPT_MAX_LEN=50
PROMPT_MIN_TAIL=6

# Set color escape wrappers — bash and zsh need different markers
# to correctly calculate visible prompt width.
if [ -n "$BASH_VERSION" ]; then
    _PS_OPEN='\[' _PS_CLOSE='\]'
elif [ -n "$ZSH_VERSION" ]; then
    _PS_OPEN='%{' _PS_CLOSE='%}'
fi

_C_RESET="${_PS_OPEN}\033[0m${_PS_CLOSE}"
_C_GREEN="${_PS_OPEN}\033[0;32m${_PS_CLOSE}"
_C_RED="${_PS_OPEN}\033[0;31m${_PS_CLOSE}"
_C_CYAN="${_PS_OPEN}\033[0;36m${_PS_CLOSE}"
_C_BLUE="${_PS_OPEN}\033[0;34m${_PS_CLOSE}"

_prompt_venv() {
    if [ -n "$VIRTUAL_ENV" ]; then
        printf '(%s) ' "$(basename "$VIRTUAL_ENV")"
    fi
}

_prompt_git() {
    local branch
    branch="$(git rev-parse --abbrev-ref HEAD 2>/dev/null)" || return
    if [ "$branch" = "HEAD" ]; then
        branch="$(git rev-parse --short HEAD 2>/dev/null)"
    fi
    printf ' (%s)' "$branch"
}

# Abbreviate path: ~/projects/myapp/src -> ~/p/m/src
# Then truncate if the total prompt line exceeds PROMPT_MAX_LEN.
_prompt_path() {
    local raw_path
    raw_path="${PWD/#$HOME/~}"

    # Split into parts. IFS=/ makes read split on slashes.
    local parts=()
    local IFS='/'
    read -r -a parts <<< "$raw_path"
    # Handle zsh arrays (1-indexed) vs bash (0-indexed)
    if [ -n "$ZSH_VERSION" ]; then
        parts=("${(@s:/:)raw_path}")
    fi

    local count=${#parts[@]}

    # Nothing to abbreviate if path is short
    if [ "$count" -le 2 ]; then
        printf '%s' "$raw_path"
        return
    fi

    # Abbreviate all parents to first char, keep last dir full
    local abbreviated=""
    local i=0
    for p in "${parts[@]}"; do
        i=$((i + 1))
        if [ "$i" -eq "$count" ]; then
            abbreviated="${abbreviated}${p}"
        elif [ "$p" = "~" ] || [ "$p" = "" ]; then
            abbreviated="${abbreviated}${p}/"
        else
            abbreviated="${abbreviated}${p:0:1}/"
        fi
    done

    local tail="${parts[$((count - 1))]}"
    if [ -n "$ZSH_VERSION" ]; then
        tail="${parts[$count]}"
    fi

    # Measure total visible prompt length (without color codes)
    local venv_text="$(_prompt_venv)"
    local git_text="$(_prompt_git)"
    local user_host
    user_host="$(whoami)@$(hostname -s)"
    # +3 for ":" separator, " " before $, and "$ " at end
    local fixed_len=$(( ${#venv_text} + ${#user_host} + ${#git_text} + 3 ))
    local avail=$(( PROMPT_MAX_LEN - fixed_len ))

    # If abbreviated path fits, use it
    if [ "${#abbreviated}" -le "$avail" ]; then
        printf '%s' "$abbreviated"
        return
    fi

    # Truncate last folder with "..."
    local prefix=""
    i=0
    for p in "${parts[@]}"; do
        i=$((i + 1))
        if [ "$i" -ge "$((count))" ]; then
            break
        fi
        if [ "$p" = "~" ] || [ "$p" = "" ]; then
            prefix="${prefix}${p}/"
        else
            prefix="${prefix}${p:0:1}/"
        fi
    done

    local tail_avail=$(( avail - ${#prefix} - 3 ))
    if [ "$tail_avail" -ge "$PROMPT_MIN_TAIL" ]; then
        printf '%s%s...' "$prefix" "${tail:0:$tail_avail}"
        return
    fi

    # Last folder would be too short — skip middle dirs with "..."
    # Format: ~/p/.../lastfolder
    local head="${parts[0]}"
    if [ -n "$ZSH_VERSION" ]; then
        head="${parts[1]}"
    fi
    if [ "$head" = "~" ] || [ "$head" = "" ]; then
        prefix="${head}/"
    else
        prefix="${head:0:1}/"
    fi
    # Add second dir abbreviated + .../
    if [ "$count" -gt 3 ]; then
        local second="${parts[1]}"
        if [ -n "$ZSH_VERSION" ]; then
            second="${parts[2]}"
        fi
        prefix="${prefix}${second:0:1}/.../"
    else
        prefix="${prefix}.../"
    fi

    tail_avail=$(( avail - ${#prefix} - 3 ))
    if [ "$tail_avail" -ge "$PROMPT_MIN_TAIL" ]; then
        printf '%s%s...' "$prefix" "${tail:0:$tail_avail}"
        return
    fi

    # Last resort: show as much of the tail as we can
    if [ "$tail_avail" -gt 0 ]; then
        printf '%s%s...' "$prefix" "${tail:0:$tail_avail}"
    else
        printf '%s%s' "$prefix" "$tail"
    fi
}

_prompt_build() {
    local venv git_info path_str symbol user_host

    venv="$(_prompt_venv)"
    git_info="$(_prompt_git)"
    path_str="$(_prompt_path)"

    if [ "$(id -u)" -eq 0 ]; then
        user_host="${_C_RED}$(whoami)@$(hostname -s)${_C_RESET}"
        symbol="#"
    else
        user_host="${_C_GREEN}$(whoami)@$(hostname -s)${_C_RESET}"
        symbol="$"
    fi

    local colored_path="${_C_CYAN}${path_str}${_C_RESET}"
    local colored_git=""
    if [ -n "$git_info" ]; then
        colored_git=" ${_C_BLUE}${git_info}${_C_RESET}"
    fi

    printf '%s%s:%s%s %s ' "$venv" "$user_host" "$colored_path" "$colored_git" "$symbol"
}

if [ -n "$BASH_VERSION" ]; then
    PROMPT_COMMAND='PS1="$(_prompt_build)"'
elif [ -n "$ZSH_VERSION" ]; then
    precmd() { PS1="$(_prompt_build)"; }
fi
