#!/bin/bash
set -euo pipefail

readonly BACKUP_DIR="/mnt/nas_buffalo/MyFolder/Backup/plex"
readonly N_KEEP=21
readonly SERVICE="plex"
readonly DATE_STR="$(date +%Y%m%d_%H%M%S)"
readonly ARCHIVE="${BACKUP_DIR}/config_${DATE_STR}.tgz"

# スクリプトのある場所に移動
cd "$(dirname "$0")"

# バックアップ先を作成
mkdir -p "$BACKUP_DIR"

# 途中で失敗しても最後に起動（dockerエラーは握り潰す）
trap 'docker compose up -d "'"$SERVICE"'" >/dev/null 2>&1 || true' EXIT

# コンテナを停止
docker compose stop "$SERVICE"

# バックアップを作成
tar -czvf "$ARCHIVE" \
  --exclude='config/Library/Application Support/Plex Media Server/Cache' \
  ./config

# ローテーション
if find "$BACKUP_DIR" -maxdepth 1 -type f -name 'config_*.tgz' | grep -q .; then
  find "$BACKUP_DIR" -maxdepth 1 -type f -name 'config_*.tgz' -printf '%T@ %p\0' \
    | sort -z -nr \
    | tail -z -n +$((N_KEEP + 1)) \
    | cut -z -d' ' -f2- \
    | xargs -0 -r rm --
fi
