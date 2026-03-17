# Nmap for Android (Fork)

This is a fork of [Nmap](https://nmap.org/), cross-compiled and modified to run on Android devices (AArch64, Android API 24).

---
            
## About

Nmap ("Network Mapper") is a powerful open-source tool for network discovery and security auditing. This fork adapts Nmap to Android using the official Android NDK toolchain.

---

## Modifications

- Cross-compiled with Android NDK r27 for ARM64 (aarch64), Android API 24.
- Fixed compatibility issues in `libdnet` for Android.
- Fixed SUN_LEN macro definition for Android socket support.
- Uses bundled libpcap and libpcre2 libraries.
- Includes BoringSSL for SSL/TLS support.
- Fixed BoringSSL compatibility issues in nsock and ncat.
- Minor Android-specific tweaks to make it run smoothly on Android devices.

---

## Build Instructions

### Prerequisites

- Linux host system
- Android NDK r27 or compatible version installed
- `make`, `gcc`, `clang`, `autoconf`, `automake`, `libtool` installed
- `pkg-config` installed
- `cmake` (for BoringSSL)
- `python3` (optional, for some scripts)

### Steps

```bash
# Clone the repo
git clone https://github.com/aeticusdev/nmap-android.git
cd nmap-android

# Set your NDK path (adjust if needed)
export NDK_HOME=/opt/android-ndk
export TOOLCHAIN=$HOME/Android/sdk/ndk/27.1.12297006/toolchains/llvm/prebuilt/linux-x86_64
export PATH=$TOOLCHAIN/bin:$PATH

# Export cross-compile tools for aarch64 Android 24
export CC=aarch64-linux-android24-clang
export CXX=aarch64-linux-android24-clang++
export AR=llvm-ar
export RANLIB=llvm-ranlib

# Build BoringSSL for Android
git clone https://github.com/google/boringssl.git
cd boringssl
mkdir -p build && cd build
cmake -DCMAKE_TOOLCHAIN_FILE=$NDK_HOME/build/cmake/android.toolchain.cmake \
      -DANDROID_ABI=arm64-v8a \
      -DANDROID_PLATFORM=android-24 \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_PREFIX=../install \
      -DBUILD_SHARED_LIBS=OFF \
      -DCMAKE_CXX_STANDARD=17 ..
make ssl crypto
cd ../..
mkdir -p boringssl/lib
ln -sf boringssl/build/libssl.a boringssl/lib/
ln -sf boringssl/build/libcrypto.a boringssl/lib/

# Build bundled libpcap
cd libpcap
./configure --host=aarch64-linux-android CC=$CC AR=$AR RANLIB=$RANLIB --without-libnl
make clean && make
cd ..

# Build bundled libpcre2
cd libpcre
./configure --host=aarch64-linux-android CC=$CC AR=$AR RANLIB=$RANLIB --disable-shared --enable-static
make clean && make
cd ..

# Configure and build Nmap with BoringSSL
export CPPFLAGS="-I$PWD/libpcap -I$PWD/libpcre/src -I$PWD/boringssl/include"
export LDFLAGS="-L$PWD/libpcap -L$PWD/libpcre/.libs -L$PWD/boringssl/lib"

./configure \
    --host=aarch64-linux-android \
    --with-libpcap=included \
    --with-libpcre=included \
    --with-openssl=$PWD/boringssl \
    --disable-zenmap \
    --disable-nmap-update \
    --without-liblua \
    --without-libssh2 \
    CC=$CC \
    CXX=$CXX \
    AR=$AR \
    RANLIB=$RANLIB \
    CPPFLAGS="$CPPFLAGS" \
    LDFLAGS="$LDFLAGS" \
    ac_cv_lib_crypto_BIO_int_ctrl=yes \
    ac_cv_lib_ssl_SSL_new=yes \
    ac_cv_func_EVP_sha256=yes

# Build
make -j$(nproc)

# After build, binaries will be at:
# ./nmap
# ./ncat/ncat
# ./nping/nping
```

### Alternative: Use build script

```bash
chmod +x build-android.sh
./build-android.sh
```

---

## Usage

Push the binaries and required library to your Android device:

```bash
adb push nmap /data/local/tmp/
adb push ncat/ncat /data/local/tmp/
adb push nping/nping /data/local/tmp/
adb push $NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64/sysroot/usr/lib/aarch64-linux-android/libc++_shared.so /data/local/tmp/

adb shell
cd /data/local/tmp
chmod +x nmap ncat nping

# Run with library path set
LD_LIBRARY_PATH=/data/local/tmp ./nmap --version
LD_LIBRARY_PATH=/data/local/tmp ./nmap -sP 127.0.0.1
```

---

## Compiled Binaries

The build produces the following ARM64 Android executables:

- `nmap` - Main Nmap scanner (approximately 27MB with BoringSSL)
- `ncat/ncat` - Network utility for reading/writing network connections (approximately 19MB with BoringSSL)
- `nping/nping` - Network packet generator (approximately 20MB with BoringSSL)

All binaries are:
- ELF 64-bit LSB pie executable
- ARM aarch64 architecture
- Dynamically linked
- Built for Android API 24
- Built with NDK r27b
- Linked with BoringSSL for SSL/TLS support

Note: You need to include `libc++_shared.so` from the NDK when running the binaries.

---

## Features

Available in this build:
- TCP/UDP port scanning
- Host discovery
- Service/version detection
- OS detection
- NSE (Nmap Scripting Engine) - basic support
- SSL/TLS support via BoringSSL
- Nping packet generation
- Ncat networking utility with SSL support

Not available in this build:
- LibSSH2 support (disabled)
- Lua scripting (disabled)
- Zenmap GUI (disabled)

---

## License

This project is based on Nmap, licensed under the **Nmap Public Source License (NPSL)**.

You **must keep all original copyright notices and license info intact**.

See the official Nmap legal page for details:
https://nmap.org/book/man-legal.html

---

## Disclaimer

Use at your own risk. No warranties or guarantees.
