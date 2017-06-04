#!/bin/bash

# Determine our root path and current GIT commit hash (short)
ROOT_PATH=$(dirname $(readlink -f $0))
GIT_REF=$(git log --pretty=format:'%h' -n 1)

# Check if magento2/env exists (needed for build)
if [[ ! -f $ROOT_PATH/magento2/env ]]; then
  echo "Environment file $ROOT_PATH/magento2/env not found, please create it"
  exit 1
fi

# Register QEMU if running on x64
if [[ $(uname -m) =~ "x86" ]]; then
  echo "Enabling ARM emulation with qemu"
  docker run --rm --privileged multiarch/qemu-user-static:register --reset
fi

build_image() {
  # TODO: Extend functionality to include loggin on errors, etc
  CONTEXT_PATH=$1
  TAG=$2

  echo -n "Building ${TAG}... "
  docker build $CONTEXT_PATH -t $TAG
}

# Build phpfpm base image (we will create customized version later)
build_image $ROOT_PATH/phpfpm-base magento2-rpi/phpfpm-base:$GIT_REF

# Build redis, mariadb and varnish image
build_image $ROOT_PATH/redis magento2-rpi/redis:$GIT_REF
build_image $ROOT_PATH/mariadb magento2-rpi/mariadb:$GIT_REF
build_image $ROOT_PATH/varnish magento2-rpi/varnish:$GIT_REF

# Start Magento2 build environment and start building
GIT_REF=$GIT_REF docker-compose -f magento2/docker-compose.yml up -d
GIT_REF=$GIT_REF docker-compose -f magento2/docker-compose.yml exec --user=app php /data/build.sh

# Dump database into dynamic folder
GIT_REF=$GIT_REF docker-compose -f magento2/docker-compose.yml exec mariadb /usr/bin/mysqldump -pmagento2 magento2 > dynamic/database.sql

# Bring Magento2 build environment down
GIT_REF=$GIT_REF docker-compose -f magento2/docker-compose.yml down -v

# Remove composer_home contents, it contains auth.json and cached files
rm -rf magento2/build/magento2/var/composer_home/*

# Move media to dynamic
rm -rf dynamic/media
mv magento2/build/magento2/pub/media dynamic/

# Create Magento2 nginx image
rm -rf nginx/magento2
mkdir -p nginx/magento2
cp -r magento2/build/magento2/pub nginx/magento2/pub
build_image $ROOT_PATH/nginx magento2-rpi/nginx:$GIT_REF

# Create Magento2 phpfpm image
rm -rf phpfpm/magento2
cp -r magento2/build/magento2 phpfpm/
chmod a+rwX -R phpfpm/magento2/var/cache phpfpm/magento2/var/log phpfpm/magento2/var/tmp phpfpm/magento2/var/generation
find phpfpm/magento2/vendor/ -name "*.jpg" -type f -delete
find phpfpm/magento2/vendor/ -name "*.js" -type f -delete
find phpfpm/magento2/vendor/ -name "*.less" -type f -delete
rm -f phpfpm/Dockerfile
sed -e "s/###GIT_REF###/$GIT_REF/" phpfpm/Dockerfile.tpl > phpfpm/Dockerfile
build_image $ROOT_PATH/phpfpm magento2-rpi/phpfpm:$GIT_REF
