#!/usr/bin/env sh

# Download the database dump from the latest GitHub workflow
# Usage: ./backup_download.sh [workflow_id]

set -eux

workflow_id="${1:-$(gh api "repos/{owner}/{repo}/actions/runs" | jq -r '.workflow_runs[] | select(.name == "Backup" and .conclusion == "success") | .id'  | sed 's/"//g' | head -n 1)}"

gh run download "$workflow_id" -n backup.dump
