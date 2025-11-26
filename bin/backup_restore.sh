#!/usr/bin/env sh

# Restore the PostgreSQL database from a dump file
# Usage: ./backup_restore.sh [dump_file] [database_name] [num_jobs]

set -eux

dump_file="${1:-backup.dump}"
database_name="${2:-postgres}"
num_jobs="${3:-$(getconf _NPROCESSORS_ONLN)}"

pg_restore "$dump_file" -d "$database_name" --no-acl --no-owner --no-privileges -j "$num_jobs" --disable-triggers
