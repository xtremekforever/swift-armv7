#!/bin/bash

set -e

# Build container
source ./swift-builder/swift-builder-common
./swift-builder/build-container.sh

BUILD_SCRIPT=${BUILD_SCRIPT:=./build.sh}

# Build Swift
echo "Building Swift ${SWIFT_TAG} using ${DOCKER_TAG}..."
docker run \
    --rm -ti \
    --user ${USER}:${USER} \
    --volume $(pwd):/src \
    --workdir /src \
    -e SWIFT_VERSION=${SWIFT_TAG} \
    -e STAGING_DIR=${STAGING_DIR} \
    -e INSTALL_TAR=${INSTALL_TAG} \
    -e SKIP_FETCH_SOURCES=${SKIP_FETCH_SOURCES} \
    -e SWIFT_TARGET_ARCH=${SWIFT_TARGET_ARCH} \
    ${DOCKER_TAG} ${BUILD_SCRIPT}
