#!/bin/bash

ROOT_PATH=$(dirname $(readlink -f $0))
GIT_REF=$(git log --pretty=format:'%h' -n 1)



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
  docker build $CONTEXT_PATH -q -t $TAG
}

# Build base images (we will create customized versions later)
build_image $ROOT_PATH/nginx magento2-rpi/nginx-base:$GIT_REF
build_image $ROOT_PATH/phpfpm magento2-rpi/phpfpm-base:$GIT_REF

# Build other images (will not be customized)
build_image $ROOT_PATH/redis magento2-rpi/redis:$GIT_REF
build_image $ROOT_PATH/mariadb magento2-rpi/mariadb:$GIT_REF
build_image $ROOT_PATH/varnish magento2-rpi/varnish:$GIT_REF

