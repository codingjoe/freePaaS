#!/usr/bin/env sh

set -eu

# Script to set up a remote host for deployment
# This script is designed to be executed on the remote host (piped via SSH)
# Usage: cat setup_remote_host.sh | ssh user@host sh -s -- <ssh_public_key>

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <ssh_public_key>"
    exit 1
fi

ssh_public_key=$1

# =============================================================================
# STEP 1: Create github user with sudo privileges
# =============================================================================

echo "Setting up github user..."
if ! id github >/dev/null 2>&1; then
    sudo useradd -m -d /home/github -s /bin/bash github
    echo "Created github user."
else
    echo "github user already exists."
fi

echo "Granting sudo privileges to github user..."
echo "github ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/github > /dev/null
sudo chmod 440 /etc/sudoers.d/github

echo "Creating SSH directory for github user..."
sudo mkdir -p /home/github/.ssh
sudo chmod 700 /home/github/.ssh
sudo chown github:github /home/github/.ssh

# =============================================================================
# STEP 2: Set up SSH key for github user
# =============================================================================

echo "Setting up SSH key for github user..."
echo "${ssh_public_key}" | sudo tee /home/github/.ssh/authorized_keys > /dev/null
sudo chmod 600 /home/github/.ssh/authorized_keys
sudo chown github:github /home/github/.ssh/authorized_keys
echo "SSH key configured for github user."

# =============================================================================
# STEP 3: Install Docker Engine and set up collaborator user
# =============================================================================

echo "Checking if Docker is installed..."
if ! command -v docker >/dev/null 2>&1; then
    echo "Installing Docker..."
    newgrp docker || true
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh ./get-docker.sh --dry-run
    echo "Docker installed successfully."
else
    echo "Docker is already installed."
fi

echo "Setting up collaborator user..."
if ! id collaborator >/dev/null 2>&1; then
    sudo useradd -r -s /usr/sbin/nologin -m -d /home/collaborator collaborator
    echo "Created collaborator user."
else
    echo "collaborator user already exists."
fi

echo "Configuring Docker access for github user..."
sudo usermod -aG docker github || true
sudo loginctl enable-linger github || true

echo "Configuring Docker access for collaborator user..."
sudo usermod -aG docker collaborator || true
sudo loginctl enable-linger collaborator || true

echo "Creating SSH directory for collaborator user..."
sudo mkdir -p /home/collaborator/.ssh
sudo chmod 700 /home/collaborator/.ssh
sudo touch /home/collaborator/.ssh/authorized_keys
sudo chmod 600 /home/collaborator/.ssh/authorized_keys
sudo chown -R collaborator:collaborator /home/collaborator/.ssh

echo "Remote host setup complete!"
