#!/usr/bin/env sh

set -eu

echo "Creating environment form template..."
gh repo create --template codingjoe/python-container
cd python-container || exit 1
mv .env.template .env

echo "Setting up your development environment..."
uv sync --dev

echo "Setting up your production environment..."
gh secret set POSTGRES_PASSWORD --env production  < python -c "import secrets; print(secrets.token_urlsafe())"
gh secret set REDIS_PASSWORD --env production  < python -c "import secrets; print(secrets.token_urlsafe())"
read -rp "Enter the hostname for your production environment (e.g., example.com): " HOSTNAME
gh variable set HOSTNAME="${HOSTNAME}" --env production

echo "Done! Finally setup your Admin user here: https://id.${HOSTNAME}/setup"
open "https://id.${HOSTNAME}/setup"
