# Configurable
source .config
source swift-define

set -e

# Build paths
SWIFT_SRCDIR=$SRC_ROOT/downloads/swift-swift-${SWIFT_VERSION}-RELEASE
LIBDISPATCH_SRCDIR=$SRC_ROOT/downloads/swift-corelibs-libdispatch-swift-${SWIFT_VERSION}-RELEASE
SWIFT_BUILDDIR=$SRC_ROOT/build/swift-armv7
SWIFTPM_DESTINATION_FILE=$SRC_ROOT/build/$SWIFT_TARGET_NAME-toolchain.json
SWIFT_CMAKE_TOOLCHAIN_FILE=$SRC_ROOT/build/linux-$SWIFT_TARGET_ARCH-toolchain.cmake
SWIFT_INSTALL_PREFIX=$SRC_ROOT/build/swift-armv7-install/usr

# Compilation flags
EXTRA_INCLUDE_FLAGS="-I${STAGING_DIR}/usr/include/c++/10 -I${STAGING_DIR}/usr/include"
RUNTIME_FLAGS="-w -fuse-ld=lld --sysroot=${STAGING_DIR} -target armv7-unknown-linux-gnueabihf -march=armv7-a -mthumb -mfpu=neon -mfloat-abi=hard -B${STAGING_DIR}/usr/lib/c++/10 -B${STAGING_DIR}/usr/lib -B${STAGING_DIR}/lib -B${STAGING_DIR}/usr/lib/arm-linux-gnueabihf -B${STAGING_DIR}/lib/arm-linux-gnueabihf -B${STAGING_DIR}/usr/lib/gcc/arm-linux-gnueabihf/10"
LINK_FLAGS="--sysroot=${STAGING_DIR} -target armv7-unknown-linux-gnueabihf -march=armv7-a -mthumb -mfpu=neon -mfloat-abi=hard -latomic"

echo "Create Swift build folder ${SWIFT_BUILDDIR}"
mkdir -p $SWIFT_BUILDDIR
mkdir -p $SWIFT_INSTALL_PREFIX

echo "Configure Swift"
rm -rf $SWIFT_BUILDDIR/CMakeCache.txt
LIBS="-latomic" cmake -S $SWIFT_SRCDIR -B $SWIFT_BUILDDIR -G Ninja \
		-DCMAKE_INSTALL_PREFIX=${SWIFT_INSTALL_PREFIX} \
		-DCMAKE_COLOR_MAKEFILE=OFF \
		-DBUILD_DOC=OFF \
		-DBUILD_DOCS=OFF \
		-DBUILD_EXAMPLE=OFF \
		-DBUILD_EXAMPLES=OFF \
		-DBUILD_TEST=OFF \
		-DBUILD_TESTS=OFF \
		-DBUILD_TESTING=OFF \
		-DBUILD_SHARED_LIBS=ON \
		-DCMAKE_BUILD_TYPE=${SWIFT_BUILD_CONFIGURATION} \
        -DCMAKE_C_COMPILER=$SWIFT_NATIVE_PATH/clang \
        -DCMAKE_CXX_COMPILER=$SWIFT_NATIVE_PATH/clang++ \
        -DCMAKE_C_FLAGS="${RUNTIME_FLAGS} ${EXTRA_INCLUDE_FLAGS}" \
        -DCMAKE_CXX_FLAGS="${RUNTIME_FLAGS} ${EXTRA_INCLUDE_FLAGS}" \
        -DCMAKE_C_LINK_FLAGS="${LINK_FLAGS}" \
        -DCMAKE_CXX_LINK_FLAGS="${LINK_FLAGS}" \
		-DSWIFT_USE_LINKER=lld \
        -DLLVM_USE_LINKER=lld \
        -DLLVM_DIR=${SWIFT_LLVM_DIR}/lib/cmake/llvm \
        -DLLVM_BUILD_LIBRARY_DIR=${SWIFT_LLVM_DIR} \
        -DLLVM_TEMPORARILY_ALLOW_OLD_TOOLCHAIN=ON \
        -DSWIFT_BUILD_RUNTIME_WITH_HOST_COMPILER=ON \
        -DSWIFT_NATIVE_CLANG_TOOLS_PATH=$SWIFT_NATIVE_PATH \
        -DSWIFT_NATIVE_SWIFT_TOOLS_PATH=$SWIFT_NATIVE_PATH \
        -DSWIFT_BUILD_AST_ANALYZER=OFF \
        -DSWIFT_BUILD_DYNAMIC_SDK_OVERLAY=ON \
        -DSWIFT_BUILD_DYNAMIC_STDLIB=ON \
        -DSWIFT_BUILD_REMOTE_MIRROR=OFF \
        -DSWIFT_BUILD_SOURCEKIT=OFF \
        -DSWIFT_BUILD_STDLIB_EXTRA_TOOLCHAIN_CONTENT=OFF \
        -DSWIFT_BUILD_SYNTAXPARSERLIB=OFF \
        -DSWIFT_BUILD_REMOTE_MIRROR=OFF \
        -DSWIFT_ENABLE_SOURCEKIT_TESTS=OFF \
        -DSWIFT_INCLUDE_DOCS=OFF \
        -DSWIFT_INCLUDE_TOOLS=OFF \
        -DSWIFT_INCLUDE_TESTS=OFF \
        -DSWIFT_LIBRARY_EVOLUTION=0 \
        -DSWIFT_RUNTIME_OS_VERSIONING=OFF \
        -DSWIFT_HOST_VARIANT_ARCH=$SWIFT_TARGET_ARCH \
        -DSWIFT_SDKS=LINUX \
        -DSWIFT_SDK_LINUX_ARCH_${SWIFT_TARGET_ARCH}_PATH=${STAGING_DIR}  \
        -DSWIFT_SDK_LINUX_ARCH_${SWIFT_TARGET_ARCH}_LIBC_INCLUDE_DIRECTORY=${STAGING_DIR}/usr/include  \
        -DSWIFT_SDK_LINUX_ARCH_${SWIFT_TARGET_ARCH}_LIBC_ARCHITECTURE_INCLUDE_DIRECTORY=${STAGING_DIR}/usr/include/arm-linux-gnueabihf \
        -DSWIFT_LINUX_${SWIFT_TARGET_ARCH}_ICU_I18N=${STAGING_DIR}/usr/lib/arm-linux-gnueabihf/libicui18n.so \
        -DSWIFT_LINUX_${SWIFT_TARGET_ARCH}_ICU_UC=${STAGING_DIR}/usr/lib/arm-linux-gnueabihf/libicuuc.so \
        -DICU_I18N_LIBRARIES=${STAGING_DIR}/usr/lib/arm-linux-gnueabihf/libicui18n.so \
        -DICU_UC_LIBRARIES=${STAGING_DIR}/usr/lib/arm-linux-gnueabihf/libicuuc.so \
        -DZLIB_LIBRARY=${STAGING_DIR}/usr/lib/arm-linux-gnueabihf/libz.so \
        -DSWIFT_PATH_TO_LIBDISPATCH_SOURCE=${LIBDISPATCH_SRCDIR} \
        -DSWIFT_ENABLE_EXPERIMENTAL_CONCURRENCY=ON \

echo "Build Swift StdLib"
(cd $SWIFT_BUILDDIR && ninja)

echo "Install Swift StdLib"
(cd $SWIFT_BUILDDIR && ninja install)

echo "Install to Debian sysroot"
sudo cp -rf ${SWIFT_INSTALL_PREFIX}/* ${STAGING_DIR}/usr/local/
