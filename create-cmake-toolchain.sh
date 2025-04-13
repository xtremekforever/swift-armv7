#!/bin/bash
set -e
source swift-define

cat <<EOT > $CROSS_TOOLCHAIN_FILE
set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR ${CMAKE_TARGET_ARCH})
set(CMAKE_SYSROOT ${STAGING_DIR})
set(CMAKE_Swift_COMPILER_TARGET ${SWIFT_TARGET_NAME})

set(TOOLCHAIN_PREFIX ${SWIFT_TARGET_NAME}-)
set(TOOLCHAIN_TRIPLE ${SWIFT_TARGET_NAME})
find_program(BINUTILS_PATH ${TOOLCHAIN_PREFIX}gcc NO_CACHE)

if (NOT BINUTILS_PATH)
    message(FATAL_ERROR "ARM GCC toolchain not found")
endif ()

get_filename_component(ARM_TOOLCHAIN_DIR ${BINUTILS_PATH} DIRECTORY)
set(ARM_GCC_C_COMPILER ${TOOLCHAIN_PREFIX}gcc)
execute_process(COMMAND ${ARM_GCC_C_COMPILER} -print-sysroot
        OUTPUT_VARIABLE ARM_GCC_SYSROOT OUTPUT_STRIP_TRAILING_WHITESPACE)
# get GNU ARM GCC version
execute_process(COMMAND ${ARM_GCC_C_COMPILER} --version
        OUTPUT_VARIABLE ARM_GCC_VERSION OUTPUT_STRIP_TRAILING_WHITESPACE)
string(REGEX MATCH "[0-9]+\.[0-9]+\.[0-9]+" ARM_GCC_VERSION ${ARM_GCC_VERSION})
# set compiler triple
set(triple ${TOOLCHAIN_TRIPLE})
set(CMAKE_ASM_COMPILER_TARGET ${triple})
set(CMAKE_C_COMPILER_TARGET ${triple})
set(CMAKE_CXX_COMPILER_TARGET ${triple})

set(CMAKE_C_FLAGS_INIT " -B${ARM_TOOLCHAIN_DIR}")
set(CMAKE_CXX_FLAGS_INIT " -B${ARM_TOOLCHAIN_DIR} ")
# Without that flag CMake is not able to pass test compilation check
if (${CMAKE_VERSION} VERSION_EQUAL "3.6.0" OR ${CMAKE_VERSION} VERSION_GREATER "3.6")
    set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)
else ()
    set(CMAKE_EXE_LINKER_FLAGS_INIT "-nostdlib")
endif ()

set(CMAKE_OBJCOPY llvm-objcopy CACHE INTERNAL "objcopy tool")
set(CMAKE_SIZE_UTIL llvm-size CACHE INTERNAL "size tool")
# Default C compiler flags
set(CMAKE_C_FLAGS_DEBUG_INIT "-g3 -Og -Wall -pedantic -DDEBUG")
set(CMAKE_C_FLAGS_DEBUG "${CMAKE_C_FLAGS_DEBUG_INIT}" CACHE STRING "" FORCE)
set(CMAKE_C_FLAGS_RELEASE_INIT "-O3 -Wall")
set(CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE_INIT}" CACHE STRING "" FORCE)
set(CMAKE_C_FLAGS_MINSIZEREL_INIT "-Oz -Wall")
set(CMAKE_C_FLAGS_MINSIZEREL "${CMAKE_C_FLAGS_MINSIZEREL_INIT}" CACHE STRING "" FORCE)
set(CMAKE_C_FLAGS_RELWITHDEBINFO_INIT "-O2 -g -Wall")
set(CMAKE_C_FLAGS_RELWITHDEBINFO "${CMAKE_C_FLAGS_RELWITHDEBINFO_INIT}" CACHE STRING "" FORCE)
# Default C++ compiler flags
set(TOOLCHAIN_CXX_INCLUDE_DIRS_FLAG "")
string(APPEND TOOLCHAIN_CXX_INCLUDE_DIRS_FLAG " -cxx-isystem ${ARM_GCC_SYSROOT}/include/c++/${ARM_GCC_VERSION}")
string(APPEND TOOLCHAIN_CXX_INCLUDE_DIRS_FLAG " -cxx-isystem ${ARM_GCC_SYSROOT}/include/c++/${ARM_GCC_VERSION}/arm-none-eabi")
string(APPEND TOOLCHAIN_CXX_INCLUDE_DIRS_FLAG " -cxx-isystem ${ARM_GCC_SYSROOT}/include/c++/${ARM_GCC_VERSION}/backward")
set(CMAKE_CXX_FLAGS_DEBUG_INIT "-g3 -Og -Wall -pedantic -DDEBUG ${TOOLCHAIN_CXX_INCLUDE_DIRS_FLAG}")
set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG_INIT}" CACHE STRING "" FORCE)
set(CMAKE_CXX_FLAGS_RELEASE_INIT "-O3 -Wall ${TOOLCHAIN_CXX_INCLUDE_DIRS_FLAG}")
set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE_INIT}" CACHE STRING "" FORCE)
set(CMAKE_CXX_FLAGS_MINSIZEREL_INIT "-Oz -Wall ${TOOLCHAIN_CXX_INCLUDE_DIRS_FLAG}")
set(CMAKE_CXX_FLAGS_MINSIZEREL "${CMAKE_CXX_FLAGS_MINSIZEREL_INIT}" CACHE STRING "" FORCE)
set(CMAKE_CXX_FLAGS_RELWITHDEBINFO_INIT "-O2 -g -Wall ${TOOLCHAIN_CXX_INCLUDE_DIRS_FLAG}")
set(CMAKE_CXX_FLAGS_RELWITHDEBINFO "${CMAKE_CXX_FLAGS_RELWITHDEBINFO_INIT}" CACHE STRING "" FORCE)

set(CMAKE_SYSROOT ${ARM_GCC_SYSROOT})
set(CMAKE_FIND_ROOT_PATH ${ARM_GCC_SYSROOT})
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY BOTH)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE BOTH)
EOT
