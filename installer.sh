#!/bin/bash

check_for_bckp() {
    if [ -d /etc/backup ]; then
        echo "Backup directory found"
        return 1
    fi
    if [ -f /usr/bin/bckp ]; then
        echo "bckp command found"
        return 1
    fi
    return 0
}

bckp() {
    check_for_bckp
    if [ $? -eq 1 ]; then
        echo "bckp already installed"
        return 0
    fi
    uuid=$(cat /proc/sys/kernel/random/uuid) 
    echo "$uuid"
    echo "Installing bckp command"
    chmod +x src/bckp.py
    cp src/bckp.py /usr/bin/bckp
    mkdir -p /etc/backup/
    touch /etc/backup/.bckp.conf
    echo [BACKUPS] >> /etc/backup/.bckp.conf
    echo [PATHS] >> /etc/backup/.bckp.conf
    echo [CONFIG] >> /etc/backup/.bckp.conf
    echo namespace = $uuid >> /etc/backup/.bckp.conf
    return 1
}

show_help() {
    echo "Usage: instalador.sh [OPTION]"
    echo "Options:"
    echo "  -h, --help          Show this help message and exit"
    echo "  -i, --install       Install bckp"
    echo "  -u, --uninstall     Uninstall bckp"
    exit 0
}

###############################################################################

if [ "$1" = "-h" ] || [ "$1" = "--help" ] || [ $# -eq 0 ]; then
    show_help
fi

if [ "$(id -u)" = "0" ]; then
    if [ "$1" = "-u" ]; then
        echo "Uninstalling bckp"
        rm /usr/bin/bckp
        rm -r /etc/backup
        check_for_bckp
        if [ $? -eq 0 ]; then
            echo "Uninstallation complete"
        else
            echo "Uninstallation failed"
        fi    
    elif [ "$1" = "-i" ]; then
        bckp 
        if [ $? -eq 1 ]; then
            echo "Installation complete"
        else
            echo "Installation failed"
        fi    
    else
        echo "Error: invalid parameters"
    fi
else
    echo "This script must be run as sudo" 1>&2
fi

