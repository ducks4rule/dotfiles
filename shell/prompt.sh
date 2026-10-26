# (venv) u@host:~/p/myapp (main) $

PROMPT_MAX_LEN=50
PROMPT_MIN_TAIL=6

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
    [ -n "$VIRTUAL_ENV" ] && printf '(%s) ' "$(basename "$VIRTUAL_ENV")"
}

_prompt_git() {
    local branch
    branch="$(git rev-parse --abbrev-ref HEAD 2>/dev/null)" || return
    [ "$branch" = "HEAD" ] && branch="$(git rev-parse --short HEAD 2>/dev/null)"
    printf ' (%s)' "$branch"
}

_prompt_path() {
    local raw_path="${PWD/#$HOME/~}"

    local parts=()
    if [ -n "$ZSH_VERSION" ]; then
        parts=("${(@s:/:)raw_path}")
    else
        local IFS='/'
        read -r -a parts <<< "$raw_path"
    fi

    local count=${#parts[@]}
    if [ "$count" -le 2 ]; then
        printf '%s' "$raw_path"
        return
    fi

    # Abbreviate parents to first char, keep last dir full
    local abbreviated="" i=0
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
    [ -n "$ZSH_VERSION" ] && tail="${parts[$count]}"

    local venv_text="$(_prompt_venv)"
    local git_text="$(_prompt_git)"
    local user_host="$(whoami)@$(hostname -s)"
    local fixed_len=$(( ${#venv_text} + ${#user_host} + ${#git_text} + 3 ))
    local avail=$(( PROMPT_MAX_LEN - fixed_len ))

    if [ "${#abbreviated}" -le "$avail" ]; then
        printf '%s' "$abbreviated"
        return
    fi

    # Truncate last folder
    local prefix="" i=0
    for p in "${parts[@]}"; do
        i=$((i + 1))
        [ "$i" -ge "$count" ] && break
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

    # Skip middle dirs: ~/p/.../lastfolder
    local head="${parts[0]}"
    [ -n "$ZSH_VERSION" ] && head="${parts[1]}"
    if [ "$head" = "~" ] || [ "$head" = "" ]; then
        prefix="${head}/"
    else
        prefix="${head:0:1}/"
    fi
    if [ "$count" -gt 3 ]; then
        local second="${parts[1]}"
        [ -n "$ZSH_VERSION" ] && second="${parts[2]}"
        prefix="${prefix}${second:0:1}/.../"
    else
        prefix="${prefix}.../"
    fi

    tail_avail=$(( avail - ${#prefix} - 3 ))
    if [ "$tail_avail" -ge "$PROMPT_MIN_TAIL" ]; then
        printf '%s%s...' "$prefix" "${tail:0:$tail_avail}"
        return
    fi

    if [ "$tail_avail" -gt 0 ]; then
        printf '%s%s...' "$prefix" "${tail:0:$tail_avail}"
    else
        printf '%s%s' "$prefix" "$tail"
    fi
}

_prompt_build() {
    local venv="$(_prompt_venv)"
    local git_info="$(_prompt_git)"
    local path_str="$(_prompt_path)"
    local symbol="$" user_host="${_C_GREEN}$(whoami)@$(hostname -s)${_C_RESET}"

    if [ "$(id -u)" -eq 0 ]; then
        user_host="${_C_RED}$(whoami)@$(hostname -s)${_C_RESET}"
        symbol="#"
    fi

    local colored_git=""
    [ -n "$git_info" ] && colored_git=" ${_C_BLUE}${git_info}${_C_RESET}"

    printf '%s%s:%s%s%s %s ' "$venv" "$user_host" "${_C_CYAN}${path_str}${_C_RESET}" "$colored_git" "" "$symbol"
}

if [ -n "$BASH_VERSION" ]; then
    PROMPT_COMMAND='PS1="$(_prompt_build)"'
elif [ -n "$ZSH_VERSION" ]; then
    precmd() { PS1="$(_prompt_build)"; }
fi
