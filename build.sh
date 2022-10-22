#!/bin/bash
set -e
source swift-define

if [[ $OSTYPE == 'darwin'* ]]; then
    echo "Install macOS build dependencies"
    ./setup-mac.sh
fi

# Fetch and patch sources
./fetch-sources.sh
./fetch-binaries.sh

# Generate Xcode toolchain
if [[ $OSTYPE == 'darwin'* && ! -d "$XCTOOLCHAIN" ]]; then
    ./generate-xcode-toolchain.sh /tmp/ ./downloads/${SWIFT_VERSION}-osx.pkg ./downloads/swift-armv7.tar.gz
    mkdir -p $XCTOOLCHAIN
    mv /tmp/cross-toolchain/swift-armv7.xctoolchain/* $XCTOOLCHAIN/
    #rm -rf $XCTOOLCHAIN/usr/lib/*
fi

# Cleanup previous build
rm -rf $STAGING_DIR/usr/lib/swift*

# Build LLVM
if [[ -d "$LLVM_INSTALL_PREFIX" ]]; then
    echo "Using built LLVM"
else
    ./build-llvm.sh
fi

# Build Swift
./build-swift-stdlib.sh
./build-dispatch.sh
./build-foundation.sh
./build-xctest.sh

# Archive
./build-tar.sh

# Update Xcode toolchain
if [[ $OSTYPE == 'darwin'* ]]; then
    echo "Updated xctoolchain sysroot"
    SYSROOT=$STAGING_DIR
    export STAGING_DIR=$XCTOOLCHAIN

fi

# Cross compile test package
./generate-swiftpm-toolchain.sh
./build-swift-hello.sh
