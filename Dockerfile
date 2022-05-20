# DEBIAN 11
FROM debian:bullseye

LABEL org.opencontainers.image.authors="Vanessa Mello"

# ENVIRONMENTs GOES HERE
ENV TERM=xterm

# REMOVE SH (DASH), LINK SH TO BASH
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

# PREVENT TO START AUTOMATICALLY BEFORE INSTALL PACKAGE
#RUN printf '#!/bin/sh\nexit 0' > /usr/sbin/policy-rc.d
RUN printf 'echo exit 101' > /usr/sbin/policy-rc.d
RUN chmod +x /usr/sbin/policy-rc.d

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
    iputils-ping \
    net-tools 

# CHANGE WORKDIR
WORKDIR /opt

# CREATE DIR
RUN mkdir -p /opt/scripts
RUN mkdir -p /etc/haproxy/certs/

# CREATE VAR LOG
RUN touch /var/log/haproxy.log

# CREATE USER HAPROXY
RUN adduser --system --group haproxy 

# INSTALL TELEGRAF
COPY src/telegraf_1.21.4-1_amd64.deb   .
RUN dpkg -i telegraf_1.21.4-1_amd64.deb \
    && rm -rf telegraf_1.21.4-1_amd64.deb

# COPY NEEDED FILES
COPY  files/certs/fullchain.pem         /etc/haproxy/certs/fullchain.pem 
COPY  files/certs/fullchain.pem.key     /etc/haproxy/certs/fullchain.pem.key
COPY  files/rsync-haproxy.conf    /etc/rsyslog.d/haproxy.conf
COPY  files/telegraf/telegraf.conf     /etc/telegraf/telegraf.conf
COPY  files/telegraf/telegraf.init     /etc/init.d/telegraf

# TESTAR 403
COPY  files/haproxy-403.cfg       /etc/haproxy/haproxy-403.cfg
# THROTTLING IP
COPY  files/haproxy-429.cfg       /etc/haproxy/haproxy.cfg
# THROTTLING HOST
COPY  files/haproxy-429-425.cfg   /etc/haproxy/haproxy-429-425.cfg
COPY  files/rates.map             /etc/haproxy/rates.map
COPY  files/start.sh              /opt/scripts/start.sh

# ERRORS CUSTOM PAGE
COPY  files/errors/400.http       /etc/haproxy/errors/400.http
COPY  files/errors/403.http       /etc/haproxy/errors/403.http
COPY  files/errors/408.http       /etc/haproxy/errors/408.http
COPY  files/errors/429.http       /etc/haproxy/errors/429.http
COPY  files/errors/500.http       /etc/haproxy/errors/500.http
COPY  files/errors/502.http       /etc/haproxy/errors/502.http
COPY  files/errors/503.http       /etc/haproxy/errors/503.http
COPY  files/errors/504.http       /etc/haproxy/errors/504.http

# START
RUN   chmod 755 /opt/scripts/start.sh
RUN   ln -s /opt/scripts/start.sh        /usr/local/bin/start

# DIR CREATION / LINKS / CHMODS / CHOWN
RUN chown haproxy:haproxy    /var/log/haproxy.log
RUN chmod 755 /etc/init.d/telegraf 

# ADD USER TELEGRAF TO GROUP HAPROXY
RUN usermod -a -G haproxy telegraf

EXPOSE 80 443

# CLEAN THE CONTAINER
RUN apt-get clean

CMD ["start", "daemonize"]
