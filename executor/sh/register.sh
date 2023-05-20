#!/usr/bin/env sh

role="$1"

# App installation tasks on a local client node. Runs first
#
#
if [ "$role" = 'client' ]; then
    carburator print terminal fyi \
        "Firewalld installs nothing on client, skipping..."
    exit 0
fi

# App installation tasks on remote node.
#
#
carburator print terminal info "Executing firewalld install script"

# TODO: Untested below
if carburator has program apt; then
    carburator sudo apt update
    carburator sudo apt -y install firewalld

elif carburator has program pacman; then
    carburator sudo pacman update
    carburator sudo pacman -Suy firewalld

elif carburator has program yum; then
    carburator sudo yum makecache --refresh
    carburator sudo yum install firewalld

elif carburator has program dnf; then
    carburator sudo dnf makecache --refresh
    carburator sudo dnf -y install firewalld

else
    carburator print terminal error \
        "Unable to detect package manager from client node linux"
    exit 120
fi

if carburator has program ufw; then
    carburator sudo ufw disable
fi

if ! carburator sudo firewall-cmd --state | grep -q 'running'; then
    carburator print terminal error \
    "Installation of firewalld failed, service state is not 'running'"
    exit 120
fi

# Enable masquerading
carburator sudo firewall-cmd --add-masquerade --permanent
