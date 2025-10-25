#!/usr/bin/env sh

set -eu

read -r "Enter the name of your project: " PROJECT_NAME
echo "Creating environment form template..."
gh repo create --template --private codingjoe/freePaaS "${PROJECT_NAME}"
cd "${PROJECT_NAME}" || exit 1
mv .env.template .env

echo "Setting up your development environment..."
uv sync --dev

echo "Setting up your production environment..."
gh secret set POSTGRES_PASSWORD --env production  < python -c "import secrets; print(secrets.token_urlsafe())"
gh secret set REDIS_PASSWORD --env production  < python -c "import secrets; print(secrets.token_urlsafe())"
read -r "Enter the hostname for your production environment (e.g., example.com): " HOSTNAME
gh variable set HOSTNAME="${HOSTNAME}" --env production

echo "Done! Finally setup your Admin user here: https://id.${HOSTNAME}/setup"
open "https://id.${HOSTNAME}/setup"
