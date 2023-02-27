#!/usr/bin/env bash

role="$1"

# App installation tasks on a local client node. Runs first
#
#
if [ "$role" = 'client' ]; then
    carburator print terminal fyi \
        "Firewalld installs nothing on client, skipping..."
    exit
fi

# App installation tasks on remote node.
#
#
carburator print terminal info "Executing firewalld install script"

carburator sudo apt update
carburator sudo apt -y install firewalld

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
