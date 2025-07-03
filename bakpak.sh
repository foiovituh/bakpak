#!/bin/bash -e
readonly TRY_HELP_COMMAND="Try 'bakpak -h' for more information"
readonly LOGS_DIRECTORY="${HOME}/.bakpak/logs"
readonly LOG_SUCCESS_PATH="${LOGS_DIRECTORY}/successes.log"
readonly LOG_ERROR_PATH="${LOGS_DIRECTORY}/errors.log"
readonly EXECUTION_PATH="$(dirname "$0")"
readonly VERSION='3.0.0'

readonly CRON_SYNTAX_REGEX='^([0-9*/,-]+)[[:space:]]+'\
'([0-9*/,-]+)[[:space:]]+'\
'([0-9*/,-]+)[[:space:]]+'\
'([0-9*/,-]+)[[:space:]]+'\
'([0-9*/,-]+)$'

readonly UNSAFE_INPUTS_REGEX='^[a-zA-Z0-9_ ./-]+$'

get_timestamp() {
  date +"%Y-%m-%dT%H:%M:%S"
}

echo_and_exit() {
  echo "$1"
  exit "$2"
}

log() {
  echo -e "$(get_timestamp) | ${1}"
}

warn() {
  local message="[WARN] ${1}"
  log "$message" | tee -a "$LOG_ERROR_PATH"
  echo -e "\n---\n"
  echo_and_exit "$TRY_HELP_COMMAND" 1
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
  -u           Uncompressed mode - create a .tar without gzip compression
  -d           Dry-run mode - no backups will be created, only  displayed
  -c           Schedule backup as a cron job using the specified cron expression

Examples:
  bakpak -f ~/Documents -t /mnt/docs_backup
  bakpak -f ~/Tests -t /mnt/backup_simulations -d
  bakpak -f /home/user/folder -t /mnt/backups -c "0 17 1 * *"
  bakpak -f ~/projects/president -t /mnt/d/band -p uncompressed_site_project -u

Author:
  Vituh        <foiovituh@outlook.com>
  GitHub:      https://github.com/foiovituh
EOF
  exit 0 
}

block_unsafe_inputs() {
  for input in "$@"; do
    if [[ -n "$input" && ! "$input" =~ $UNSAFE_INPUTS_REGEX ]]; then
      warn "Potentially dangerous characters detected in input: ${input}"
    fi
  done
}

configure_crontab() {
  if ! command -v crontab >/dev/null 2>&1; then
    warn "Missing 'crontab' command. Install cron to use -c"
  fi

  if [[ "$dry_run" == true ]]; then
    warn 'Cannot schedule cron job in dry-run mode (-d)'
  fi

  if [[ "${FROM:0:1}" != "/" ]]; then
    warn 'Absolute path required for -f: e.g., /home/user/folder'
  fi

  if [[ "${TO:0:1}" != "/" ]]; then
    warn 'Absolute path required for -t: e.g., /mnt/backups)'
  fi
  
  if ! [[ "$cron_expression" =~ $CRON_SYNTAX_REGEX ]]; then
    warn "Invalid cron expression: '${cron_expression}'"
  fi

  local cron_cmd="/usr/local/bin/bakpak ${clean_arguments[*]}"

  if crontab -l 2>/dev/null | grep -Fq "$cron_cmd"; then
    log 'Cron job already exists, it will not be duplicated'
  else
    (crontab -l 2>/dev/null; echo "$cron_expression $cron_cmd") | crontab -
    log "Cron job created: ${cron_expression} ${cron_cmd}"
  fi

  exit 0
}

check_required_arguments() {
  if [[ -z "${1:-}" ]]; then
    warn "Missing required argument: '-f <readable_path>'"
  elif [[ ! -d "$1" ]]; then
    warn "From directory (-f) does not exist: ${1}"
  elif [[ ! -r "$1" ]]; then
    warn "From directory (-f) is not readable: ${1}"
  fi

  if [[ -z "${2:-}" ]]; then
    warn "Missing required argument: '-t <writable_path>'"
  elif [[ ! -d "$2" ]]; then
    warn "To directory (-t) does not exist: ${2}"
  elif [[ ! -w "$2" ]]; then
    warn "To directory (-t) is not writable: ${2}"
  fi
}

create_backup() {
  check_required_arguments "$FROM" "$TO"

  local from_dirname="$(dirname "$FROM")"
  local from_basename="$(basename "$FROM")"
  local file_prefix="${PREFIX:-$from_basename}"
  local file_path="${TO}${file_prefix}_$(date +'%F_%H-%M-%S').${extension}"
  local cmd="tar -czf \"$file_path\" -C \"$from_dirname\" \"$from_basename\""

  if [[ "$dry_run" == true ]]; then
    echo_and_exit "$cmd" 0
  fi

  if ! eval "$cmd"; then
    warn "Backup failed! See ${LOG_ERROR_PATH} for details"
  fi

  log "Backup created at: ${file_path}" | tee -a "$LOG_SUCCESS_PATH"
}

mkdir -p "$LOGS_DIRECTORY"

if [[ $# -eq 0 ]]; then
  echo_and_exit "$TRY_HELP_COMMAND" 0
fi

clean_arguments=()
cron_expression=""
extension="tar.gz"
dry_run=false

while getopts ":f:t:p:udc:vh" opt; do
  case "$opt" in
    f)
      readonly FROM="$OPTARG"
      clean_arguments+=("-f" "$FROM")
      ;;
    t)
      readonly TO="${OPTARG%/}/"
      clean_arguments+=("-t" "$TO")
      ;;
    p)
      readonly PREFIX="$OPTARG"
      clean_arguments+=("-p" "$PREFIX")
      ;;
    u)
      extension="tar"
      clean_arguments+=("-u")
      ;;
    d)
      dry_run=true
      clean_arguments+=("-d")
      ;;
    c) readonly cron_expression="$OPTARG" ;;
    v) echo_and_exit "bakpak version ${VERSION}" 0 ;;
    h) show_help ;;
    \?) warn "Invalid option: -${OPTARG}" ;;
    :) warn "The (-${OPTARG}) option requires argument" ;;
  esac
done

block_unsafe_inputs "$FROM" "$TO" "${PREFIX:-}"

if [[ -n "$cron_expression" ]]; then
  configure_crontab "${cron_expression}"
fi


create_backup
