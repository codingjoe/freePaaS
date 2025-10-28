#!/usr/bin/env sh

set -eu

printf "Enter the name of your project: "
read -r project_name
echo "Creating environment form template..."
gh repo create --private --clone --template codingjoe/freePaaS "${project_name}"
cd "${project_name}" || exit 1
mv .env.example .env

echo "Setting up your development environment..."
uv sync --dev

echo "Setting up your production environment..."
gh api -X PUT "/repos/{owner}/{repo}/environments/production" > /dev/null
python -c "import secrets; print(secrets.token_urlsafe())" | gh secret set POSTGRES_PASSWORD --env production
python -c "import secrets; print(secrets.token_urlsafe())" | gh secret set REDIS_PASSWORD --env production

printf "Enter the hostname for your production environment (e.g., example.com): "
read -r hostname

printf "Enter the SSH username for your production server: "
read -r ssh_username

# Test SSH connection
ssh -T "${ssh_username}@${hostname}" "echo 'SSH connection to ${hostname} successful.'"

echo "$hostname" gh variable set HOSTNAME --env production
echo "$ssh_username" gh variable set SSH_USERNAME --env production

# Create SSH_PRIVATE_KEY
KEY_PATH="$(mktemp -d)"
ssh-keygen -t ed25519 -C "freePaaS deployment key" -f "${KEY_PATH}/deploy_key" -N ""
gh secret set SSH_PRIVATE_KEY --env production < "${KEY_PATH}/deploy_key"
gh secret set SSH_PUBLIC_KEY --env production < "${KEY_PATH}/deploy_key.pub"
ssh-copy-id -i "${KEY_PATH}/deploy_key.pub" "${ssh_username}@${hostname}"

echo "Done! Finally setup your Admin user here: https://id.${hostname}/setup"
open "https://id.${hostname}/setup"
