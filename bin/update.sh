#!/bin/bash

# check for root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

# update system's package list
apt update

# upgrade all installed packages
apt upgrade -y

# remove packages that are now no longer needed
apt autoremove -y

# update Pi-hole Core, Web Interface and FTL
pihole -up

# disable default gravity update schedule
sed -e '/pihole updateGravity/ s/^#*/#/' -i /etc/cron.d/pihole

# update pihole-updatelists script
pihole-updatelists --update

# wipe all adlists and domains
sqlite3 /etc/pihole/gravity.db "DELETE FROM adlist"
sqlite3 /etc/pihole/gravity.db "DELETE FROM adlist_by_group"
sqlite3 /etc/pihole/gravity.db "DELETE FROM domainlist"
sqlite3 /etc/pihole/gravity.db "DELETE FROM domainlist_by_group"

# update Pi-hole's lists from remote sources
pihole-updatelists
