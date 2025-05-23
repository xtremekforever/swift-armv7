#!/bin/bash
set -e
source swift-define

# Combine build output
rm -rf $INSTALL_TAR
rm -rf $INSTALL_PREFIX
mkdir -p $INSTALL_PREFIX
cp -rf $SWIFT_INSTALL_PREFIX/* $INSTALL_PREFIX/
cp -rf $LIBDISPATCH_INSTALL_PREFIX/* $INSTALL_PREFIX/
cp -rf $FOUNDATION_INSTALL_PREFIX/* $INSTALL_PREFIX/
cp -rf $XCTEST_INSTALL_PREFIX/* $INSTALL_PREFIX/
if [ -d $SWIFT_TESTING_INSTALL_PREFIX ]; then
    cp -rf $SWIFT_TESTING_INSTALL_PREFIX/* $INSTALL_PREFIX/
fi

cp -rf $FOUNDATION_STATIC_INSTALL_PREFIX/* $INSTALL_PREFIX/
cp -rf $LIBDISPATCH_STATIC_INSTALL_PREFIX/* $INSTALL_PREFIX/

# compress
cd $SRC_ROOT/build/swift-install
tar -czvf $INSTALL_TAR .
