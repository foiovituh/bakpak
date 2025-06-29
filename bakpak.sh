#!/bin/bash -e
declare -r LOG_ERROR_PATH='/tmp/bakpak_errors.log';
declare -r EXECUTION_PATH="$(dirname "$0")"
declare -r VERSION='1.0.0'
declare -r TAR_GZ='tar.gz'
declare -r TAR='tar'

timestamp() {
    date +"%Y-%m-%dT%H:%M:%S"
}

log() {
    echo -e "$(timestamp) | $1"
}

warn() {
    log "[WARN] $1"
    echo -e "\n---\n"
    show_help 1
}

show_help() {
    cat <<EOF
Basic usage:   bakpak <from> <to>

Required:
  -f <path>    Directory to back up (must be readable)
  -t <path>    Directory to store the compressed archive (must be writable)

Optional:
  -v           Show script version
  -h           Show this help message
  -p           Custom backup name prefix
  -u           Create uncompressed .tar archive

Examples:
  bakpak -f ~/Documents -t /mnt/backups
  bakpak -f ~/Documents -t /mnt/backups -p docs-backup -u

Author:
  Vituh        <foiovituh@outlook.com>
  GitHub:      https://github.com/foiovituh
EOF
    exit "$1"
}

create_backup() {
    if [[ ! -d "$from" || ! -r "$from" || ! -d "$to" || ! -w "$to" ]]; then
        warn "-f must be readable and -t must be writable directories"
    fi

    local extension="$([[ "$uncompressed" == true ]] \
        && echo "$TAR" \
        || echo "$TAR_GZ")"
    
    local from_basename="$(basename "$from")"
    local file_prefix="${prefix:-$from_basename}"

    if ! tar -czf "${to}${file_prefix}_$(date +"%F_%H-%M-%S").${extension}" \
        -C "$(dirname "$from")" "$from_basename" \
        2> "$LOG_ERROR_PATH"; then
        warn "Backup failed! See ${LOG_ERROR_PATH} for details."
    fi

    log "Backup created at: ${to}"
}

uncompressed=false

while getopts ":f:t:p:uvh" opt; do
  case "$opt" in
    f) declare -r from="$OPTARG" ;;
    t) to="${OPTARG%/}/" ;;
    p) declare -r prefix="$OPTARG" ;;
    u) uncompressed=true ;;
    v) echo "bakpak version ${VERSION}"; exit 0 ;;
    h) show_help 0;;
    \?) warn "Invalid option: -${OPTARG}";;
    :) warn "The -${OPTARG} option requires argument";;
  esac
done

create_backup
