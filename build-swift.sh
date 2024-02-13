#!/bin/bash
set -e
source swift-define

echo "Create Swift build folder ${SWIFT_BUILDDIR}"
mkdir -p $SWIFT_BUILDDIR
mkdir -p $SWIFT_INSTALL_PREFIX

echo "Build Swift compiler"
cd $SWIFT_SRCDIR
export SKIP_XCODE_VERSION_CHECK=1
export SWIFT_NATIVE_SWIFT_TOOLS_PATH=$SWIFT_NATIVE_PATH
export SWIFT_NATIVE_CLANG_TOOLS_PATH=$SWIFT_NATIVE_PATH
export CC=$SWIFT_NATIVE_PATH/clang
export CFLAGS="${RUNTIME_FLAGS} ${EXTRA_INCLUDE_FLAGS}"
export CXXFLAGS="${RUNTIME_FLAGS} ${EXTRA_INCLUDE_FLAGS}"
export LDFLAGS="${LINK_FLAGS}"

# Build Swift
./utils/build-script -RA \
    --reconfigure \
    --skip-early-swift-driver \
    --bootstrapping=off \
    --build-toolchain-only \
    --skip-local-build \
    --skip-local-host-install \
    --swift-enable-backtracing=0 \
    --swift-threading-package=c11 \
    --swift-stdlib-supports-backtrace-reporting=0 \
    --enable-experimental-cxx-interop=0 \
    --enable-cxx-interop-swift-bridging-header=0 \
    --native-swift-tools-path=$SWIFT_NATIVE_PATH \
    --native-clang-tools-path=$SWIFT_NATIVE_PATH \
    --cross-compile-hosts=linux-armv7 \
    --cross-compile-deps-path=$STAGING_DIR \
    --cross-compile-append-host-target-to-destdir=False \
    --swift-install-components="${SWIFT_COMPONENTS}" \
    --llvm-install-components="${LLVM_COMPONENTS}" --install-llvm --install-lldb \
    --install-swift \
    --install-cmark \
    --libdispatch --foundation --xctest \
    --install-foundation --install-libdispatch --install-xctest \
    --install-destdir=$SWIFT_INSTALL_PREFIX \
    --build-dir=$SRC_ROOT/build \
    --workspace=$SRC_ROOT/downloads \
    --common-swift-flags="${SWIFTC_FLAGS}" \
    --extra-cmake-options="${EXTRA_CMAKE_OPTIONS}" \

echo "Fix Swift modules"
rm -rf ${SWIFT_INSTALL_PREFIX}/usr/lib/swift/linux/"$(uname -m)"
mkdir -p ${SWIFT_INSTALL_PREFIX}/usr/lib/swift_static/linux/${SWIFT_TARGET_ARCH}
cp -rf ${SWIFT_INSTALL_PREFIX}/usr/lib/swift_static/linux/"$(uname -m)"/* ${SWIFT_INSTALL_PREFIX}/usr/lib/swift_static/linux/${SWIFT_TARGET_ARCH}/
rm -rf ${SWIFT_INSTALL_PREFIX}/usr/lib/swift_static/linux/"$(uname -m)"
rm -rf ${SWIFT_INSTALL_PREFIX}/usr/swiftpm.json
rm -rf ${SWIFT_INSTALL_PREFIX}/usr/lib/swift/clang
ln -s ../clang/13.0.0 ${SWIFT_INSTALL_PREFIX}/usr/lib/swift/clang
