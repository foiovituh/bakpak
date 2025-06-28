#!/bin/bash -e
readonly ERRORS_LOG_FILE_PATH='/tmp/bakpak_errors.log';
readonly EXECUTION_PATH="$(dirname "$0")"
readonly SCRIPT_VERSION="1.0.0"

timestamp() {
    date +"%Y-%m-%dT%H:%M:%S"
}

log() {
    echo -e "$(timestamp) | $1"
}

show_version() {
    echo "bakpak version: $SCRIPT_VERSION"
    exit 0
}

show_help() {
    cat <<EOF
Usage: bakpak <from> <to>

from: Directory to back up (must be readable)
to:   Directory to store the compressed archive (must be writable)

Compresses the from directory and stores the archive in the to directory.
Errors are logged to /tmp/bakpak_errors.log

Options:
  -v, --version     Show script version
  -h, --help        Show this help message

Author:
  Vituh             <foiovituh@outlook.com>
  GitHub:           https://github.com/foiovituh
EOF
    exit "$1"
}

create_backup() {
    local from="$1"
    local to="$2"

    if [[ ! -d "$from" || ! -r "$from" || ! -d "$to" || ! -w "$to" ]]; then
        show_help 1
    fi

    if [[ "$to" != */ ]]; then
        to="${to}/"
    fi

    local from_basename="$(basename "$from")"

    if ! tar -czf "${to}${from_basename}_$(date +"%F_%H-%M-%S").tar.gz" \
        -C "$(dirname "$from")" "$from_basename" \
        2> "$ERRORS_LOG_FILE_PATH"; then
        log "Backup failed! See ${ERRORS_LOG_FILE_PATH} for details."
        exit 1
    fi

    log "Backup created at: ${to}"
}

readonly FIRST_ARGUMENT="$1"
readonly SECOND_ARGUMENT="$2"

case "$FIRST_ARGUMENT" in
    -v|--version)
        show_version
        ;;
    -h|--help)
        show_help 0
        ;;
esac

create_backup "$FIRST_ARGUMENT" "$SECOND_ARGUMENT"
