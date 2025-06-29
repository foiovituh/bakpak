#!/bin/bash -e
declare -r TRY_HELP_COMMAND="Try 'bakpak -h' for more information"
declare -r LOG_ERROR_PATH='/tmp/bakpak_errors.log';
declare -r EXECUTION_PATH="$(dirname "$0")"
declare -r VERSION='2.1.0'
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
  show_try_help_command 1
}

show_try_help_command() {
  echo "$TRY_HELP_COMMAND"
  exit "$1"
}

show_help() {
  cat <<EOF
Required:
  -f <path>    Directory to back up (must be readable)
  -t <path>    Directory to store the compressed archive (must be writable)

Optional:
  -v           Show script version
  -h           Show this help message
  -p           Custom backup name prefix
  -u           Uncompressed mode - create .tar archive
  -d           Dry-run mode — no backups will be created, only  displayed

Examples:
  bakpak -f ~/Documents -t /mnt/docs_backup
  bakpak -f ~/Tests -t /mnt/backup_simulations -d
  bakpak -f ~/projects/president -t /mnt/d/band -p uncompressed_site_project -u

Author:
  Vituh        <foiovituh@outlook.com>
  GitHub:      https://github.com/foiovituh
EOF
  exit "$1"
}

block_unsafe_inputs() {
  local regex='^[a-zA-Z0-9_ ./-]+$'

  for input in "$@"; do
    if [[ -n "$input" && ! "$input" =~ $regex ]]; then
      warn "Potentially dangerous characters detected in input: ${input}"
    fi
  done
}

create_backup() {
  if [[ ! -d "$from" || ! -r "$from" || ! -d "$to" || ! -w "$to" ]]; then
    warn "-f must be readable and -t must be writable directories"
  fi

  local extension="$([[ "$uncompressed" == true ]] \
    && echo "$TAR" \
    || echo "$TAR_GZ")"
  
  local from_dirname="$(dirname "$from")"
  local from_basename="$(basename "$from")"
  local file_prefix="${prefix:-$from_basename}"
  local file_path="${to}${file_prefix}_$(date +'%F_%H-%M-%S').${extension}"
  local cmd="tar -czf \"$file_path\" -C \"$from_dirname\" \"$from_basename\""

  if [[ "$dry_run" == true ]]; then
    echo "$cmd"
    exit 0;
  fi

  if ! eval "$cmd" 2> "$LOG_ERROR_PATH"; then
    warn "Backup failed! See ${LOG_ERROR_PATH} for details."
  fi

  log "Backup created at: ${file_path}"
}

uncompressed=false
dry_run=false

if [[ $# -eq 0 ]]; then
  show_try_help_command 0
fi

while getopts ":f:t:p:udvh" opt; do
  case "$opt" in
    f) declare -r from="$OPTARG" ;;
    t) to="${OPTARG%/}/" ;;
    p) declare -r prefix="$OPTARG" ;;
    u) uncompressed=true ;;
    d) dry_run=true ;;
    v) echo "bakpak version ${VERSION}"; exit 0 ;;
    h) show_help 0;;
    \?) warn "Invalid option: -${OPTARG}";;
    :) warn "The -${OPTARG} option requires argument";;
  esac
done

block_unsafe_inputs "$from" "$to" "${prefix:-}"
create_backup
