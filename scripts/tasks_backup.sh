#!/bin/bash
set -e

source "$HOME/.config/restic/env.sh"

BACKUP_PATHS=(
    "$HOME/company"
)

echo "Starting Restic Backup..."
restic backup \
    --verbose \
    --tag "automated" \
    "${BACKUP_PATHS[@]}"

echo "applying retention"
restic forget \
    --tag "automated" \
    --keep-daily 7 \
    --keep-weekly 4 \
    --keep-monthly 12 \
    --keep-yearly 11 \
    --prune

echo "Backup Cycle Complete."
