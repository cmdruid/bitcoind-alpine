#!/bin/sh
## Startup script for docker container.

###############################################################################
# Environment
###############################################################################

IMG_NAME="bitcoind-alpine"
IMG_VER="latest"
SERV_NAME=$IMG_NAME

REBUILD=0
DEVMODE=0

###############################################################################
# Methods
###############################################################################

build_image() {
  echo "Building $IMG_NAME from dockerfile ..."
  docker build --tag $IMG_NAME .
}

stop_container() {
  ## Check if previous container exists, and remove it.
  if docker container ls | grep $SERV_NAME > /dev/null 2>&1; then
    echo "Stopping current container..."
    docker container stop $SERV_NAME > /dev/null 2>&1
  fi
}

###############################################################################
# Script
###############################################################################

set -E

## Check if bitcoin binary is present.
if [ -z "$(ls build/out | grep bitcoin)" ]; then
  echo "Bitcoin binary is missing from build/out, rebuilding..."
  ./build/build.sh
fi

## If existing image is not present, build it.
IMG_EXISTS="$(docker image ls | grep $IMG_NAME)"
if [ -z "$IMG_EXISTS" ]; then
  build_image
elif [ $REBUILD -eq 1 ]; then
  docker image rm $IMG_NAME > /dev/null 2>&1
  build_image
fi

stop_container
echo "Starting $SERV_NAME container... "

if [ "$DEVMODE" -eq 1 ]; then
  docker run -it --rm \
    --name $SERV_NAME \
    --mount type=bind,source=$(pwd)/snapshot,target=/snapshot \
    --mount type=volume,source=$SERV_NAME-data,target=/data \
    --entrypoint ash \
  $IMG_NAME:$IMG_VER
else
  docker run -d --rm \
    --name $SERV_NAME \
    --mount type=bind,source=$(pwd)/snapshot,target=/snapshot \
    --mount type=volume,source=$SERV_NAME-data,target=/data \
  $IMG_NAME:$IMG_VER
fi

printf "\n
============================================================================
  Now viewing log output of $SERV_NAME container. Press Ctrl+C to exit.
  Administer this container by running 'docker exec -it $SERV_NAME ash'
============================================================================
\n\n"

docker logs -f $SERV_NAME
