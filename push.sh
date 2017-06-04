#!/bin/bash

if [[ -z "$1" ]]; then
  echo "Usage <tag> <repository_url>"
  exit 1
fi

if [[ -z "$2" ]]; then
  echo "Usage <tag> <repository_url>"
  exit 1
fi

TAG=$1
REPO=$2

docker tag magento2-rpi/redis:$TAG $REPO/magento2-rpi/redis:$TAG
docker push $REPO/magento2-rpi/redis:$TAG

docker tag magento2-rpi/mariadb:$TAG $REPO/magento2-rpi/mariadb:$TAG
docker push $REPO/magento2-rpi/mariadb:$TAG

docker tag magento2-rpi/varnish:$TAG $REPO/magento2-rpi/varnish:$TAG
docker push $REPO/magento2-rpi/varnish:$TAG

docker tag magento2-rpi/nginx:$TAG $REPO/magento2-rpi/nginx:$TAG
docker push $REPO/magento2-rpi/nginx:$TAG

docker tag magento2-rpi/phpfpm:$TAG $REPO/magento2-rpi/phpfpm:$TAG
docker push $REPO/magento2-rpi/phpfpm:$TAG
