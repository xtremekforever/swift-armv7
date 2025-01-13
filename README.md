# Swift Runtime for Linux Armv7

Since Linux armv7 is not officially supported by the Swift project ([swiftlang](https://github.com/swiftlang)), this is an effort
to maintain builds of the runtime that can be used for cross-compilation to armv7.

Some main goals:

- Build major versions of Swift (since 5.9) and provide build artifacts for various distributions that support armv7 (Ubuntu, Debian).
- Provide SDKs that can be downloaded and used to cross-compile user applications and libraries to armv7.
- Maintain a CI that can build snapshots/nightly versions of Swift to find and fix issues.

NOTE: Building for armv6 is also now supported, although it is limited to working with the `raspios`
distribution since that is the only version of Debian that supports the ARMv6 architecture. However,
this makes this project also compatible with older Raspberry Pi models such as the RPI 1, Zero, and so on.

## Compilation

There are various options for compiling Swift for armv7 with these scripts.

### Build Swift runtime cross compiled from Linux

To build for the default (Debian Bookworm) for armv7, use the `build.sh` script:

```bash
export SWIFT_NATIVE_PATH=/path/to/swift/toolchain
./build.sh
```

NOTE: The toolchain pointed to by SWIFT_NATIVE_PATH should match the version of Swift being built.
If not, failures will occur in the compilation.

### Build Swift runtime using custom sysroot

To build a custom sysroot and use it to build, run the `build-sysroot.sh` script. This requires a
working installation of Docker with [multi-platform support](https://docs.docker.com/build/building/multi-platform/) enabled.

```bash
./build-sysroot.sh ubuntu:noble
```

Then, provide the `STAGING_DIR` env variable to the build script:

```bash
export STAGING_DIR=$(pwd)/sysroot-ubuntu-noble
./build.sh
```

Extra dependencies can also be installed into the sysroot if desired or needed, which in turn will
be installed into the cross-compilation SDK (see [Building a Cross Compilation SDK for Linux](#building-a-cross-compilation-sdk-for-linux)). To do this, use:

```bash
EXTRA_DEPENDENCIES="libsqlite3-dev" ./build-sysroot debian:bookworm.sh
```

### Cross compile Swift package from Linux

```bash
export SWIFT_PACKAGE_SRCDIR=/home/user/Developer/MySwiftPackage
./build.sh # Or skip if using cached build
./build-swift-package.sh
```

### Cross compile Swift package from macOS

```bash
./generate-xcode-toolchain.sh
export SWIFT_PACKAGE_SRCDIR=/home/user/Developer/MySwiftPackage
export SWIFT_NATIVE_PATH=/tmp/cross-toolchain/debian-bookworm.sdk
./build-swift-package.sh
```

`SWIFT_PACKAGE_SRCDIR` can be set to the root of your own packages to cross compile them using `build-swift-package.sh`.

### Building a Cross Compilation SDK for Linux

After building the armv7 runtime using the `build.sh` script, you can generate a redistributable SDK
using the `build-linux-cross-sdk.sh` script. You must provide the swift tag and distribution name:

```bash
./build-linux-cross-sdk.sh swift-6.0.3-RELEASE ubuntu-noble
```

By default, the SDK will be generated to be installed at a path of /opt/$SWIFT_TAG-$DISTRIBUTION-armv7, but this can be customized by providing a different install prefix to the script:

```bash
export SDK_INSTALL_PREFIX=/home/myuser/swift-sdks
./build-linux-cross-sdk.sh swift-6.0.3-RELEASE ubuntu-noble
```

## Continuous Integration & Releases

This repo also contains CI scripts that use GitHub actions to compile different versions of Swift
for armv7 for different distributions. Artifacts are generated and published to CI runs that can
be downloaded and used locally:

- `sysroot-$DISTRIBUTION`: Contains sysroot for the given distribution, used to compile Swift and included in SDKs.
- `$SWIFT_TAG-$DISTRIBUTION-armv7-install`: Swift armv7 runtime built for the given distribution, can be installed to the target.
- `$SWIFT_TAG-$DISTRIBUTION-armv7-sdk`: The cross-compilation SDK for the given distribution, must be installed to /opt to use.

To use the SDK that is generated by the CI or published to the [Releases](https://github.com/xtremekforever/swift-armv7/releases) page, first
extract it to /opt:

```bash
sudo tar -xf swift-6.0.3-RELEASE-debian-bookworm-armv7-sdk.tar.gz -C /opt
```

Then, from a Swift package, use the `--destination` paramter to cross-compile it for the target:

```bash
swift build --destination /opt/swift-6.0.3-RELEASE-debian-bookworm-armv7/debian-bookworm.json
```
