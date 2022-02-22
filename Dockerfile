FROM debian:bullseye

LABEL org.opencontainers.image.authors="Vanessa Mello"

# ENVIRONMENTs GOES HERE
ENV TERM=xterm

# REMOVE SH (DASH) AND LINK SH TO BASH
RUN printf '#!/bin/sh\nexit 0' > /usr/sbin/policy-rc.d
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

# UPDATE & INSTALL KEYS
RUN apt-get update -y
RUN apt-get -y install gnupg2 curl

# INSTALL DEPENDENCIES
RUN apt-get update && apt-get -y install \
    cron \
    vim \
    awscli \
    dnsutils \
    rsyslog \
    iptables \
    procps \
    jq \
    openssl \
    socat \ 
    liblua5.3-0 \ 
    htop \
    haproxy=2.2.\* 

# CHANGE WORKDIR
WORKDIR /opt

# CREATE DIR
RUN mkdir -p /opt/scripts
RUN mkdir -p /etc/haproxy/certs/

# CREATE VAR LOG
RUN touch /var/log/haproxy.log

# CREATE USER HAPROXY
RUN adduser --system --group haproxy 

# COPY NEEDED FILES
COPY  files/haproxy.cfg        /etc/haproxy/haproxy.cfg
COPY  files/fullchain.pem      /etc/haproxy/certs/fullchain.pem 
COPY  files/fullchain.pem.key  /etc/haproxy/certs/fullchain.pem.key
COPY  files/rsync-haproxy.conf /etc/rsyslog.d/haproxy.conf
# TESTAR 403
COPY  files/haproxy-403.cfg   /etc/rsyslog.d/haproxy-403.conf
# THROTTLING IP
COPY  files/haproxy-429.cfg   /etc/rsyslog.d/haproxy.conf
COPY  files/start.sh          /opt/scripts/start.sh

# START
RUN   chmod 755 /opt/scripts/start.sh
RUN   ln -s /opt/scripts/start.sh        /usr/local/bin/start

# DIR CREATION / LINKS / CHMODS / CHOWN
RUN chown haproxy:haproxy    /var/log/haproxy.log

EXPOSE 80 443

# CLEAN THE CONTAINER
RUN apt-get clean


CMD ["start", "daemonize"]


