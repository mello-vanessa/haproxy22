#!/bin/bash

# Get lsb functions
. /lib/lsb/init-functions

if [ "$1" == "daemonize" ]; then
    # DAEMONIZE
    /usr/local/bin/start
    while true; do
        sleep 1000
    done
fi

    # START CRON
    /usr/sbin/cron
    # START RSYSLOG
    /etc/init.d/rsyslog start

    # START HA
    /etc/init.d/haproxy start

