# This file creates a container that runs Database (Percona) with Galera Replication.
#
# Author: Paul Czarkowski
# Date: 08/16/2014

FROM debian:wheezy
MAINTAINER Paul Czarkowski "paul@paulcz.net"

# Base Deps
RUN \
  apt-get update && apt-get install -yq \
  make \
  ca-certificates \
  net-tools \
  sudo \
  wget \
  vim \
  strace \
  lsof \
  netcat \
  lsb-release \
  locales \
  socat \
  --no-install-recommends

# generate a local to suppress warnings
RUN locale-gen en_US.UTF-8

RUN apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 0xcbcb082a1bb943db
RUN apt-key adv --keyserver keys.gnupg.net --recv-keys 1C4CBDCDCD2EFD2A
RUN add-apt-repository 'deb http://ftp.osuosl.org/pub/mariadb/repo/5.5/debian wheezy main'
RUN add-apt-repository 'deb http://repo.percona.com/apt wheezy main' && \
apt-get update && \
DEBIAN_FRONTEND=noninteractive apt-get install -y rsync galera mariadb-galera-server xtrabackup socat && \
sed -i 's/^\(bind-address\s.*\)/# \1/' /etc/mysql/my.cnf

RUN rm -rf /var/lib/mysql/*

# download latest stable etcdctl
ADD https://s3-us-west-2.amazonaws.com/opdemand/etcdctl-v0.4.5 /usr/local/bin/etcdctl
RUN chmod +x /usr/local/bin/etcdctl

# install confd
ADD https://s3-us-west-2.amazonaws.com/opdemand/confd-v0.5.0-json /usr/local/bin/confd
RUN chmod +x /usr/local/bin/confd

# Define mountable directories.
VOLUME ["/var/lib/mysql"]

ADD . /app

# Define working directory.
WORKDIR /app

RUN chmod +x /app/bin/*

# Define default command.
CMD ["/app/bin/boot"]

# Expose ports.
EXPOSE 3306 4444 4567 4568
