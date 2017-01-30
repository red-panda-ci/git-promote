#!bash

# bash completion for git-promote.
# install as:
# - Linux:   /etc/bash_completion.d/git-promote-completion.bash
# - Mac OS:  /usr/local/etc/bash_completion.d/git-promote-completion.bash
__git_promote_list_branches() {
    local nomerged=''
    if [[ ! -z "$1" ]]; then
        nomerged="--no-merged $1"
    fi
    git branch --list -r --no-color $nomerged 2> /dev/null \
        | sed 's/^ *//g' \
        | grep "^$origin/" \
        | grep -v 'HEAD' \
        | sed "s,^$origin/,," \
        | sort
}

__git_promote_parse_args_opts() {
    while [[ $# > 0 ]] ; do
        if [[ "$1" = -* ]]; then
            opts=("${opts[@]}" "$1")
            if [[ "$1" == '-m' ]]; then
                shift
            fi
        else
            args=("${args[@]}" "$1")
        fi
        shift
    done
}

_git_promote() {
    local OPTS=(
        '--dry-run'
        '--help'
        '--local'
        '-m'
        '--no-edit'
        '--nopull'
        '--nopush'
    )
    local cur="${COMP_WORDS[$COMP_CWORD]}"

    local args=()
    local opts=()
    __git_promote_parse_args_opts "${COMP_WORDS[@]:2:$COMP_CWORD-2}"

    if [[ "$cur" = -* ]]; then
        local avail_opts=$(comm -23 \
            <(printf '%s\n' "${OPTS[@]}") \
            <(printf '%s\n' "${opts[@]}" | sort -u))
        __gitcomp "$avail_opts"

    elif [[ ${#args[@]} -lt 2 ]]; then
        local origin='origin'

        local from=''
        if [[ ${#args[@]} -gt 0 ]]; then
            from="$origin/${args[0]}"
        fi
        __gitcomp "$(__git_promote_list_branches "$from")"

    else
        COMPREPLY=()
    fi
}