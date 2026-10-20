#!/usr/bin/env bash

set -e

echo "Starting SSH configuration..."


OS="$(uname -s 2>/dev/null || echo unknown)"

case "$OS" in 
	Linux*|Darwin*|FreeBSD*|OpenBSD*|NetBSD*|DragonFly*)
		;;
	MSYS*|MINGW*|CYGWIN)
		echo "Windows detected, please run setup-ssh.psh1 instead by running this command: ..."
		exit 1
	;;
	*)
		echo "Unknown OS '$OS', trying anyway..."
esac

if ! command -v ssh >/dev/null 2>&1 || ! command -v ssh-keygen >/dev/null 2>&1; then
    echo "Error: SSH is not installed. Please install OpenSSH first."
    exit 1
fi

SSH_DIR="$HOME/.ssh"

mkdir -p "$SSH_DIR"
chmod 700 "$SSH_DIR"

if [ ! -f "$SSH_DIR/id_ed25519" ]; then
    echo "No SSH key found. Generating a new SSH key..."
    read -r -p "Enter your email address: " email
    ssh-keygen -t ed25519 -C "$email" -f "$SSH_DIR/id_ed25519"
else
    echo "SSH key already exists. Skipping key generation."
fi

eval "$(ssh-agent -s)" >/dev/null

ssh-add "$SSH_DIR/id_ed25519"

echo ""
echo "SSH configuration completed!"
echo "Your public SSH key is:"
cat "$SSH_DIR/id_ed25519.pub"

echo ""
echo "Copy the public key above and add it to your GitHub account."
echo "Go to: https://github.com/settings/keys"
