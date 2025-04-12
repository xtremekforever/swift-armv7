#!/bin/bash
set -e
source swift-define

echo "Create Swift build folder ${SWIFT_BUILDDIR}"
mkdir -p $SWIFT_BUILDDIR
mkdir -p $SWIFT_INSTALL_PREFIX

echo "Configure Swift"
rm -rf $SWIFT_BUILDDIR/CMakeCache.txt
cmake -S $SWIFT_SRCDIR -B $SWIFT_BUILDDIR -G Ninja \
        -DCMAKE_INSTALL_PREFIX=${SWIFT_INSTALL_PREFIX} \
        -DBUILD_SHARED_LIBS=ON \
        -DCMAKE_BUILD_TYPE=${SWIFT_BUILD_CONFIGURATION} \
        -DCMAKE_C_COMPILER=$SWIFT_NATIVE_PATH/clang \
        -DCMAKE_CXX_COMPILER=$SWIFT_NATIVE_PATH/clang++ \
        -DCMAKE_C_FLAGS="${RUNTIME_FLAGS}" \
        -DCMAKE_CXX_FLAGS="${RUNTIME_FLAGS}" \
        -DCMAKE_C_LINK_FLAGS="${LINK_FLAGS}" \
        -DCMAKE_CXX_LINK_FLAGS="${LINK_FLAGS}" \
        -DCMAKE_SYSROOT="${STAGING_DIR}" \
        -DSWIFT_USE_LINKER=lld \
        -DLLVM_USE_LINKER=lld \
        -DLLVM_DIR=${LLVM_BUILDDIR}/lib/cmake/llvm \
        -DLLVM_BUILD_LIBRARY_DIR=${LLVM_BUILDDIR} \
        -DSWIFT_BUILD_RUNTIME_WITH_HOST_COMPILER=ON \
        -DSWIFT_NATIVE_CLANG_TOOLS_PATH=$SWIFT_NATIVE_PATH \
        -DSWIFT_NATIVE_SWIFT_TOOLS_PATH=$SWIFT_NATIVE_PATH \
        -DSWIFT_BUILD_DYNAMIC_SDK_OVERLAY=ON \
        -DSWIFT_BUILD_DYNAMIC_STDLIB=ON \
        -DSWIFT_BUILD_STATIC_STDLIB=ON \
        -DSWIFT_BUILD_REMOTE_MIRROR=ON \
        -DSWIFT_BUILD_SOURCEKIT=ON \
        -DSWIFT_BUILD_STDLIB_EXTRA_TOOLCHAIN_CONTENT=ON \
        -DSWIFT_ENABLE_SOURCEKIT_TESTS=OFF \
        -DSWIFT_INCLUDE_DOCS=OFF \
        -DSWIFT_INCLUDE_TOOLS=OFF \
        -DSWIFT_INCLUDE_TESTS=OFF \
        -DSWIFT_HOST_VARIANT_ARCH=$SWIFT_TARGET_ARCH \
        -DSWIFT_SDKS=LINUX \
        -DSWIFT_SDK_LINUX_ARCH_${SWIFT_TARGET_ARCH}_PATH=${STAGING_DIR}  \
        -DSWIFT_SDK_LINUX_CXX_OVERLAY_SWIFT_COMPILE_FLAGS="" \
        -DZLIB_LIBRARY=${STAGING_DIR}/usr/lib/libz.so \
        -DZLIB_INCLUDE_DIR=${STAGING_DIR}/usr/include \
        -DSWIFT_PATH_TO_LIBDISPATCH_SOURCE=${LIBDISPATCH_SRCDIR} \
        -DSWIFT_ENABLE_EXPERIMENTAL_CONCURRENCY=ON \
        -DSWIFT_PATH_TO_SWIFT_SYNTAX_SOURCE=${SYNTAX_SRCDIR} \
        -DSWIFT_PATH_TO_STRING_PROCESSING_SOURCE=${STRING_PROCESSING_SRCDIR} \
        -DSWIFT_ENABLE_EXPERIMENTAL_STRING_PROCESSING=ON \
        -DSWIFT_ENABLE_EXPERIMENTAL_CXX_INTEROP=ON \
        -DSWIFT_ENABLE_CXX_INTEROP_SWIFT_BRIDGING_HEADER=ON \
        -DSWIFT_BUILD_STDLIB_CXX_MODULE=ON \
        -DSWIFT_ENABLE_EXPERIMENTAL_DIFFERENTIABLE_PROGRAMMING=ON \
        -DSWIFT_ENABLE_EXPERIMENTAL_DISTRIBUTED=ON \
        -DSWIFT_ENABLE_EXPERIMENTAL_NONESCAPABLE_TYPES=ON \
        -DSWIFT_ENABLE_EXPERIMENTAL_OBSERVATION=ON \
        -DSWIFT_ENABLE_SYNCHRONIZATION=ON \
        -DSWIFT_SHOULD_BUILD_EMBEDDED_STDLIB=OFF \
        -DSWIFT_INCLUDE_TESTS=OFF \
        -DSWIFT_INCLUDE_TEST_BINARIES=OFF \
        -DSWIFT_BUILD_TEST_SUPPORT_MODULES=OFF \
        -DSWIFT_THREADING_PACKAGE=c11 \
        -DCMAKE_Swift_FLAGS_DEBUG="" \
        -DCMAKE_Swift_FLAGS_RELEASE="" \
        -DCMAKE_Swift_FLAGS_RELWITHDEBINFO="" \
        -DCMAKE_OSX_SYSROOT="" \
        -DCMAKE_EXE_LINKER_FLAGS="-L/opt/swift-armv7/sysroot-imx8/lib/aarch64-poky-linux/13.3.0/" \ 
        -DCMAKE_C_STARTUP_OBJECTS="/opt/swift-armv7/sysroot-imx8/lib/aarch64-poky-linux/13.3.0/crtbeginS.o" \
        -DCMAKE_C_END_OF_STATIC_LIBS="/opt/swift-armv7/sysroot-imx8/lib/aarch64-poky-linux/13.3.0/crtendS.o" \
        -DCMAKE_CXX_STARTUP_OBJECTS="/opt/swift-armv7/sysroot-imx8/lib/aarch64-poky-linux/13.3.0/crtbeginS.o" \
        -DCMAKE_CXX_END_OF_STATIC_LIBS="/opt/swift-armv7/sysroot-imx8/lib/aarch64-poky-linux/13.3.0/crtendS.o"
        -DCMAKE_Swift_STARTUP_OBJECTS="/opt/swift-armv7/sysroot-imx8/lib/aarch64-poky-linux/13.3.0/crtbeginS.o" \
        -DCMAKE_Swift_END_OF_STATIC_LIBS="/opt/swift-armv7/sysroot-imx8/lib/aarch64-poky-linux/13.3.0/crtendS.o" \

echo "Build Swift StdLib"
(cd $SWIFT_BUILDDIR && ninja)

echo "Install Swift StdLib"
(cd $SWIFT_BUILDDIR && ninja install)

# https://github.com/swiftlang/swift/issues/78003
echo "Fix libswiftCxx installation location..."
cp -rf ${SWIFT_INSTALL_PREFIX}/lib/swift/linux/libswiftCxx*.a ${SWIFT_INSTALL_PREFIX}/lib/swift_static/linux

echo "Install Swift Stdlib to sysroot"
cp -rf ${SWIFT_INSTALL_PREFIX}/* ${STAGING_DIR}/usr/
