#!/usr/bin/env sh

set -eu

# Test if GitHub CLI is installed
if ! command -v gh >/dev/null 2>&1; then
  echo "GitHub CLI (gh) is not installed. Please install it from https://cli.github.com/ and try again."
  exit 1
fi

# org or user
gh_user=$(gh api user --jq .login)


sluggify() {
  echo "$1" | iconv -t "ascii//TRANSLIT" | sed -r "s/[~\^]+//g" | sed -r "s/[^a-zA-Z0-9]+/-/g" | sed -r "s/^-+\|-+$//g" | tr '[:upper:]' '[:lower:]'
}

echo "Enter your domain name (e.g., example.com): "
read -r hostname
project_name=$(sluggify "$hostname")

echo "Enter your SSH user name for ${hostname} (${USER})?: "
read -r input_ssh_username
if [ -n "$input_ssh_username" ]; then
  ssh_username=$input_ssh_username
fi


if ! ssh -T "${ssh_username}@${hostname}" "echo 'SSH connection to ${hostname} successful.'"; then
  echo "SSH connection to ${hostname} failed. Please ensure you can SSH into the server before proceeding."
  exit 1
fi

echo "Enter your project name (${project_name}): "
read -r input_project_name
if [ -n "$input_project_name" ]; then
  project_name=$input_project_name
fi

printf "Enter your GitHub username or organization name (default %s): " "$gh_user"
read -r gh_owner
if [ -n "$gh_owner" ]; then
  gh_owner=$gh_user
  gh_is_org=true
fi

echo "Create a new OAUTH App:"
# Create OAUTH App
if [ "$gh_is_org" = true ]; then
  echo "https://github.com/organizations/${gh_owner}/settings/apps"
  open "https://github.com/organizations/${gh_owner}/settings/apps"
else
  echo "https://github.com/settings/apps/new"
  open "https://github.com/settings/apps/new"
fi

echo "
Use the following values:
- Application name: ${project_name}
- Homepage URL: https://${hostname}/
- Authorization callback URL: https://dozzle.${hostname}/oauth2/github/authorization-code-callback

Please check 'Request user authorization (OAuth) during installation'.
You can disable the Webhook section.
Press any key to continue...
"

# shellcheck disable=SC2034
read -r nothing

echo "Enter your OAUTH App Client ID: "
read -r oauth_client_id
echo "Enter your OAUTH App Client Secret: "
read -r oauth_client_secret

printf "Enter the name of your project: "
read -r project_name
echo "Creating environment form template..."
gh repo create --private --clone --template codingjoe/freePaaS "${project_name}"
cd "${project_name}" || exit 1

echo "Setting up your development environment..."
mv .env.example .env
if ! command -v uv >/dev/null 2>&1; then
  echo "Installing uv..."
  curl -LsSf https://astral.sh/uv/install.sh | sh
fi
uv sync --dev

echo "Setting up your production environment on GitHub..."
gh api -X PUT "/repos/{owner}/{repo}/environments/production" > /dev/null
python -c "import secrets; print(secrets.token_urlsafe())" | gh secret set POSTGRES_PASSWORD --env production
python -c "import secrets; print(secrets.token_urlsafe())" | gh secret set REDIS_PASSWORD --env production
echo "$hostname" gh variable set hostname --env production
echo "$ssh_username" gh variable set SSH_USERNAME --env production
echo "$oauth_client_id" gh secret set GITHUB_CLIENT_ID --env production
echo "$oauth_client_secret" gh secret set GITHUB_CLIENT_SECRET --env production
# Create SSH_PRIVATE_KEY
ssh_key_path="$(mktemp -d)"
ssh-keygen -t ed25519 -C "freePaaS deployment key" -f "${ssh_key_path}/deploy_key" -N "" > /dev/null
gh secret set SSH_PRIVATE_KEY --env production < "${ssh_key_path}/deploy_key"
gh secret set SSH_PUBLIC_KEY --env production < "${ssh_key_path}/deploy_key.pub"
ssh-copy-id -i "${ssh_key_path}/deploy_key.pub" "${ssh_username}@${hostname}"

# Trigger deployment workflow
echo "Triggering deployment workflow..."
gh workflow run deploy.yml --ref main

echo "Setup complete! Your project ${project_name} is being deployed to ${hostname}."
