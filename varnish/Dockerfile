FROM hypriot/rpi-alpine:3.5
MAINTAINER Magento 2 Boys

RUN apk update \
 && apk upgrade \
 && apk add varnish

COPY start.sh /start.sh
COPY default.vcl /etc/varnish/default.vcl

ENV CACHE_SIZE      64m
ENV VARNISHD_PARAMS -p default_ttl=3600 -p default_grace=3600
ENV BACKEND_HOST    127.0.0.1
ENV BACKEND_PORT    9000

CMD /start.sh

EXPOSE 80
