#!/bin/bash
set -Eeuo pipefail

trap 'printf "Error on line %s. Update aborted.\n" "$LINENO" >&2' ERR

if [[ $EUID -ne 0 ]]; then
    echo "Please run this script as root." >&2
    exit 1
fi

# Gravity runs as the pihole user and needs access to the working directory.
cd /tmp

# Update Debian packages.
apt update
apt upgrade -y
apt autoremove -y

# Update Pi-hole and the lists updater.
pihole -up
pihole-updatelists --update

# Disable Pi-hole's default Gravity update schedule.
if [[ -f /etc/cron.d/pihole ]]; then
    sed -i '/pihole[[:space:]]\+updateGravity/ s/^#*/#/' /etc/cron.d/pihole
fi

# Recreate the Gravity database, importing any existing migration backup.
pihole -g -r recreate

# Import configured remote lists and update Gravity (UPDATE_GRAVITY=true).
pihole-updatelists
