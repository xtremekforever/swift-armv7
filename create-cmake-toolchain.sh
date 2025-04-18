#!/bin/bash
set -e
source swift-define

cat <<EOT > $CROSS_TOOLCHAIN_FILE
set(CMAKE_C_COMPILER_TARGET ${SWIFT_TARGET_NAME})
set(CMAKE_CXX_COMPILER_TARGET ${SWIFT_TARGET_NAME})
set(CMAKE_SYSROOT ${STAGING_DIR})
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR ${CMAKE_TARGET_ARCH})
set(CMAKE_Swift_COMPILER_TARGET ${SWIFT_TARGET_NAME})
EOT
