#!/usr/bin/env bash

set -e

echo "Starting SSH configuration..."

if ! command -v ssh >/dev/null 2>&1; then
    echo "Error: SSH is not installed. Please install OpenSSH first."
    exit 1
fi

mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"

if [ ! -f "$HOME/.ssh/id_ed25519" ]; then
    echo "No SSH key found. Generating a new SSH key..."
    read -r -p "Enter your email address: " email
    ssh-keygen -t ed25519 -C "$email" -f "$HOME/.ssh/id_ed25519"
else
    echo "SSH key already exists. Skipping key generation."
fi

eval "$(ssh-agent -s)" >/dev/null

ssh-add "$HOME/.ssh/id_ed25519"

echo ""
echo "SSH configuration completed!"
echo "Your public SSH key is:"
cat "$HOME/.ssh/id_ed25519.pub"

echo ""
echo "Copy the public key above and add it to your Git hosting account."
echo "For GitHub: https://github.com/settings/keys"
echo "For GitLab: https://gitlab.com/-/user_settings/ssh_keys"
