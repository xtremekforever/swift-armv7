#!/bin/bash
set -e
source swift-define

echo "Cross compile Swift package"
rm -rf $SWIFT_PACKAGE_BUILDDIR
mkdir -p $SWIFT_PACKAGE_BUILDDIR
cd $SWIFT_PACKAGE_SRCDIR
$SWIFT_NATIVE_PATH/swift build --build-tests \
    --configuration ${SWIFTPM_CONFIGURATION} \
    --scratch-path ${SWIFT_PACKAGE_BUILDDIR} \
    --destination ${SWIFTPM_DESTINATION_FILE} \
    -Xswiftc -cxx-interoperability-mode=default \
    -Xswiftc -enable-testing
