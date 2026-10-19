#!/bin/bash
set -euo pipefail

readonly BACKUP_DIR="${BACKUP_DIR:-./backup}"
readonly N_KEEP=21
readonly SERVICE="plex"
readonly DATE_STR="$(date +%Y%m%d_%H%M%S)"
readonly ARCHIVE="${BACKUP_DIR}/config_${DATE_STR}.tgz"

log() { echo "$(date '+%F %T') [$1] ${*:2}"; }

# Log the failing line and exit code
trap 'log ERROR "failed at line $LINENO (exit $?)"' ERR

# Move to the script's directory
cd "$(dirname "$0")"

log INFO "start backup -> $ARCHIVE"

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

# Ensure the container is restarted even if the script fails (ignore docker errors)
trap 'docker compose up -d "'"$SERVICE"'" >/dev/null 2>&1 || true' EXIT

# Stop the container
docker compose stop "$SERVICE"

# Create backup
tar -czf "$ARCHIVE" \
  --exclude='config/Library/Application Support/Plex Media Server/Cache' \
  ./config

# Rotation
if find "$BACKUP_DIR" -maxdepth 1 -type f -name 'config_*.tgz' | grep -q .; then
  find "$BACKUP_DIR" -maxdepth 1 -type f -name 'config_*.tgz' -printf '%T@ %p\0' \
    | sort -z -nr \
    | tail -z -n +$((N_KEEP + 1)) \
    | cut -z -d' ' -f2- \
    | xargs -0 -r rm --
fi

log INFO "done: $(du -h "$ARCHIVE" | cut -f1)"
