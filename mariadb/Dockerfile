FROM hypriot/rpi-alpine:3.5
MAINTAINER Magento2 Boys

ENV LC_ALL=en_US.UTF-8

RUN apk -U upgrade
RUN apk add mariadb mariadb-client

RUN mkdir /docker-entrypoint-initdb.d

# comment out a few problematic configuration values
# don't reverse lookup hostnames, they are usually another container
RUN sed -Ei 's/^(bind-address|log)/#&/' /etc/mysql/my.cnf \
  && echo -e 'skip-host-cache\nskip-name-resolve' | awk '{ print } $1 == "[mysqld]" && c == 0 { c = 1; system("cat") }' /etc/mysql/my.cnf > /tmp/my.cnf \
  && mv /tmp/my.cnf /etc/mysql/my.cnf

RUN rm -rf /tmp/src
RUN rm -rf /var/cache/apk/*

VOLUME /var/lib/mysql

COPY docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 3306
