#!/bin/bash
set -euo pipefail

readonly BACKUP_DIR="/mnt/nas_buffalo/MyFolder/Backup/plex"
readonly N_KEEP=21
readonly SERVICE="plex"
readonly DATE_STR="$(date +%Y%m%d_%H%M%S)"
readonly ARCHIVE="${BACKUP_DIR}/config_${DATE_STR}.tgz"

# Move to the script's directory
cd "$(dirname "$0")"

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

# Ensure the container is restarted even if the script fails (ignore docker errors)
trap 'docker compose up -d "'"$SERVICE"'" >/dev/null 2>&1 || true' EXIT

# Stop the container
docker compose stop "$SERVICE"

# Create backup
tar -czvf "$ARCHIVE" \
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
