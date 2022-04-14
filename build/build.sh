#!/bin/sh
## Build script for bitcoin-core.

###############################################################################
# Environment
###############################################################################

IMG_NAME="bitcoin-build-alpine"
IMG_VER="latest"
SERV_NAME=$IMG_NAME

BUILD_TARGET="x86_64-pc-linux-gnu"
BUILD_BRANCH="22.x"

###############################################################################
# Script
###############################################################################

set -E

BUILD_DIR="$(dirname "$(realpath "$0")")"/
echo "Current build directory: $BUILD_DIR"

if ! [ -d "$BUILD_DIR/out" ]; then
  mkdir "$BUILD_DIR/out"
fi

if [ $1 = "--rebuild" ]; then
  docker image rm $IMG_NAME > /dev/null 2>&1
fi

if docker container ls | grep $SERV_NAME > /dev/null 2>&1; then
  echo "Stopping existing container..."
  docker container stop $SERV_NAME > /dev/null 2>&1
fi

if ! docker image ls | grep $IMG_NAME > /dev/null 2>&1; then
  echo "Building $IMG_NAME from dockerfile... "
  docker build \
    --build-arg BUILD_TARGET=$BUILD_TARGET \
    --build-arg BUILD_BRANCH=$BUILD_BRANCH \
    --tag $IMG_NAME $BUILD_DIR
fi

FILENAME="bitcoin-alpine-$BUILD_TARGET-$BUILD_BRANCH"
echo "Starting build process..."

docker run -it --rm \
  --name $SERV_NAME \
  --mount type=bind,source="$BUILD_DIR/out",target=/root/bin \
  --entrypoint tar \
$IMG_NAME:$IMG_VER -czvf /root/bin/$FILENAME.tar.gz -C /root/bitcoin bitcoin-core
