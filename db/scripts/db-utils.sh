#!/bin/bash

source "$(dirname "$0")/../config/db-config.sh"

run_psql() {
    local user="$DB_USER"
    local -a args=()

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --as-postgres)
                user="postgres"
                shift
                ;;
            -f)
                args=(-f "$2")
                shift 2
                ;;
            *)
                args=(-tAc "$1")
                shift
                ;;
        esac
    done

    psql -U "$user" "${DB_HOST[@]}" -d "$DB_NAME" "${args[@]}" 2>&1 | awk 'NF'
}
