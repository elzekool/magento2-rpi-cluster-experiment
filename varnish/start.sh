#!/bin/sh

set -e

# Set backend
sed -i "s/###BACKEND_HOST###/$BACKEND_HOST/" /etc/varnish/default.vcl
sed -i "s/###BACKEND_PORT###/$BACKEND_PORT/" /etc/varnish/default.vcl

exec sh -c \
  "exec varnishd -F \
  -f /etc/varnish/default.vcl \
  -s malloc,$CACHE_SIZE \
  $VARNISHD_PARAMS"
