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

# rebuilds the Pi-hole Gravity database from scratch using all configured blocklists
pihole -g -r recreate

# update Pi-hole's lists from remote sources
pihole-updatelists
