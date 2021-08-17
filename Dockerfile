FROM ubuntu:focal
MAINTAINER BIND 9 Developers <bind9-dev@isc.org>

ENV DEBIAN_FRONTEND noninteractive
ENV LC_ALL C.UTF-8

RUN apt-get -qqqy update
RUN apt-get -qqqy install apt-utils software-properties-common dctrl-tools wget apt-transport-https
RUN rm /etc/dpkg/dpkg.cfg.d/excludes
RUN apt-get -qqqy install dumb-init isc-dhcp-server man
RUN apt-get -qqqy autoremove
RUN apt-get -qqqy clean
RUN rm -rf /var/lib/apt/lists/*
ENV DHCPD_PROTOCOL=4
COPY util/entrypoint.sh /entrypoint.sh
COPY conf/dhcpd.conf /etc/dhcp/dhcpd.conf

ARG DEB_VERSION=1:9.11.34-1+ubuntu20.04.1+isc+1
RUN add-apt-repository -y ppa:isc/bind-esv
RUN apt-get -qqqy update && apt-get -qqqy dist-upgrade && apt-get -qqqy install bind9=$DEB_VERSION bind9utils=$DEB_VERSION

RUN wget -q http://www.webmin.com/jcameron-key.asc -O- | apt-key add -
RUN add-apt-repository -y "deb [arch=amd64] http://download.webmin.com/download/repository sarge contrib"
RUN apt-get -qqqy install webmin

VOLUME ["/etc/bind", "/var/cache/bind", "/var/lib/bind", "/var/log", "/var/lib/dhcp", "/etc/dhcp", "/etc/webmin"]

RUN mkdir -p /etc/bind && chown root:bind /etc/bind && chmod 755 /etc/bind
RUN mkdir -p /etc/dhcp && chown dhcpd:dhcpd /etc/dhcp && chmod 755 /etc/dhcp
RUN mkdir -p /var/cache/bind && chown bind:bind /var/cache/bind && chmod 755 /var/cache/bind
RUN mkdir -p /var/lib/bind && chown bind:bind /var/lib/bind && chmod 755 /var/lib/bind
RUN mkdir -p /var/lib/dhcp && chown dhcpd:dhcpd /var/lib/dhcp && chmod 755 /var/lib/dhcp
RUN mkdir -p /var/log/bind && chown bind:bind /var/log/bind && chmod 755 /var/log/bind
RUN mkdir -p /var/log/dhcp && chown dhcpd:dhcpd /var/log/dhcp && chmod 755 /var/log/dhcp
RUN mkdir -p /run/named && chown bind:bind /run/named && chmod 755 /run/named
RUN chmod 750 /entrypoint.sh && chown dhcpd:dhcpd /etc/dhcp/dhcpd.conf

EXPOSE 53/udp 53/tcp 953/tcp 10000/tcp

CMD /etc/init.d/webmin start&/entrypoint.sh&/usr/sbin/named -g -c /etc/bind/named.conf -u bind

