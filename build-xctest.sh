#!/bin/bash
set -e
source swift-define

echo "Create XCTest build folder ${XCTEST_BUILDDIR}"
mkdir -p $XCTEST_BUILDDIR
rm -rf $XCTEST_INSTALL_PREFIX
mkdir -p $XCTEST_INSTALL_PREFIX

echo "Configure XCTest"
rm -rf $XCTEST_BUILDDIR/CMakeCache.txt
cmake -S $XCTEST_SRCDIR -B $XCTEST_BUILDDIR -G Ninja \
        -DCMAKE_INSTALL_PREFIX=${XCTEST_INSTALL_PREFIX} \
        -DBUILD_SHARED_LIBS=ON \
        -DCMAKE_BUILD_TYPE=${SWIFT_BUILD_CONFIGURATION} \
        -DCMAKE_C_COMPILER=${SWIFT_NATIVE_PATH}/clang \
        -DCMAKE_CXX_COMPILER=${SWIFT_NATIVE_PATH}/clang++ \
        -DCMAKE_C_FLAGS="${RUNTIME_FLAGS}" \
        -DCMAKE_CXX_FLAGS="${RUNTIME_FLAGS}" \
        -DCMAKE_C_LINK_FLAGS="${LINK_FLAGS}" \
        -DCMAKE_CXX_LINK_FLAGS="${LINK_FLAGS}" \
        -DCMAKE_TOOLCHAIN_FILE="${CROSS_TOOLCHAIN_FILE}" \
        -DCF_DEPLOYMENT_SWIFT=ON \
        -Ddispatch_DIR="${LIBDISPATCH_BUILDDIR}/cmake/modules" \
        -DFoundation_DIR="${FOUNDATION_BUILDDIR}/cmake/modules" \
        -DCMAKE_Swift_COMPILER=${SWIFT_NATIVE_PATH}/swiftc \
        -DCMAKE_Swift_FLAGS="${SWIFTC_FLAGS}" \
        -DCMAKE_Swift_FLAGS_DEBUG="" \
        -DCMAKE_Swift_FLAGS_RELEASE="" \
        -DCMAKE_Swift_FLAGS_RELWITHDEBINFO="" \

echo "Build XCTest"
(cd $XCTEST_BUILDDIR && ninja)

echo "Install XCTest"
(cd $XCTEST_BUILDDIR && ninja install)
