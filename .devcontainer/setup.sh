#!/usr/bin/env bash
set -euo pipefail

# Make apt non-interactive (no tzdata prompts, etc.)
export DEBIAN_FRONTEND=noninteractive

# Install Ansible (with sudo)
sudo apt-get update
sudo apt-get install -y --no-install-recommends \
  software-properties-common gnupg ca-certificates curl unzip

# PPA for latest Ansible
sudo apt-add-repository --yes --update ppa:ansible/ansible
sudo apt-get install -y --no-install-recommends ansible

# Verify
ansible --version || true

# Pulumi for user `vscode` (installer writes to ~/.pulumi)
curl -fsSL https://get.pulumi.com | sh
# Persist PATH for future shells
if ! grep -q "/home/vscode/.pulumi/bin" /home/vscode/.bashrc 2>/dev/null; then
  echo 'export PATH="$PATH:/home/vscode/.pulumi/bin"' >> /home/vscode/.bashrc
  echo 'export PATH="$PATH:/home/vscode/.pulumi/bin"' >> /home/vscode/.zshrc
fi

# Clean up apt cache to keep image light (optional)
sudo rm -rf /var/lib/apt/lists/*
