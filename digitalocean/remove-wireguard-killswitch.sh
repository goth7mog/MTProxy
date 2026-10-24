#!/usr/bin/env bash

set -u

if [[ ${EUID} -ne 0 ]]; then
    printf 'Run this script as root, for example: sudo %s\n' "$0" >&2
    exit 1
fi

remove_rules() {
    local command="$1"
    local rule
    local -a arguments

    while IFS= read -r rule; do
        case "$rule" in
            "-A OUTPUT ! -o wg0 -m mark ! --mark "*)
                [[ "$rule" == *" -m addrtype ! --dst-type LOCAL -j REJECT"* ]] || continue
                ;;
            *)
                continue
                ;;
        esac

        read -r -a arguments <<< "${rule/-A OUTPUT/-D OUTPUT}"
        "$command" "${arguments[@]}"
        printf 'Removed: %s %s\n' "$command" "$rule"
    done < <("$command" -S OUTPUT)
}

remove_rules iptables

if command -v ip6tables >/dev/null 2>&1; then
    remove_rules ip6tables
fi
