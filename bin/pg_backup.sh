#!/usr/bin/env sh

set -eu
# A script to backup a PostgreSQL database using pg_dump.

printf "Backing up PostgreSQL database..."
FILENAME="./backups/$(date -u +%Y-%m-%dT%H:%M:%SZ).dump"
until docker compose exec postgres /usr/bin/pg_dump -Rc -U postgres postgres > "$FILENAME"
do
    printf "."
    sleep 1
done
echo " DONE!"
echo "Backup saved to $FILENAME"
