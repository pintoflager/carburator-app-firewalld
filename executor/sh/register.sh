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

# App installation tasks on remote node. Runs as root.
#
#
carburator print terminal info "Executing firewalld register script"

# TODO: Untested below
if carburator has program apt; then
    apt-get -y update
    apt-get -y install firewalld

elif carburator has program pacman; then
    pacman update
    pacman -Sy firewalld

elif carburator has program yum; then
    yum makecache --refresh
    yum install firewalld

elif carburator has program dnf; then
    dnf makecache --refresh
    dnf -y install firewalld

else
    carburator print terminal error \
        "Unable to detect package manager from client node linux"
    exit 120
fi

if carburator has program ufw; then
    ufw disable
fi

if ! firewall-cmd --state | grep -q 'running'; then
    carburator print terminal error \
    "Installation of firewalld failed, service state is not 'running'"
    exit 120
fi

# Enable masquerading
firewall-cmd --add-masquerade --permanent
