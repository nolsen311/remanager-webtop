#!/usr/bin/env bash
# Pulls the latest published image (built by GitHub Actions whenever
# rmitchellscott/reManager cuts a new release) and recreates the container
# if a newer image was actually downloaded. Safe to run repeatedly, e.g.
# from a daily cron job:
#
#   0 4 * * * cd /path/to/remanager-webtop && ./update.sh >> update.log 2>&1
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"

before="$(docker compose images -q remanager 2>/dev/null || true)"
docker compose pull
after="$(docker compose images -q remanager 2>/dev/null || true)"

if [ "$before" != "$after" ]; then
    echo "New image found, recreating container..."
    docker compose up -d
    docker image prune -f >/dev/null
else
    echo "Already up to date."
fi
