#!/bin/bash
set -e

# Android NDK configuration
export NDK_HOME=/opt/android-ndk
export TOOLCHAIN=/home/mostafizur/Android/sdk/ndk/27.1.12297006/toolchains/llvm/prebuilt/linux-x86_64
export PATH=$TOOLCHAIN/bin:$PATH

# Android target
export TARGET=aarch64-linux-android
export API=24

# Compiler settings
export CC=aarch64-linux-android${API}-clang
export CXX=aarch64-linux-android${API}-clang++
export AR=llvm-ar
export RANLIB=llvm-ranlib
export STRIP=llvm-strip

# Paths
NMAP_DIR=$(pwd)
PCAP_DIR=$NMAP_DIR/libpcap
PCRE_DIR=$NMAP_DIR/libpcre
BORINGSSL_DIR=$NMAP_DIR/boringssl

# Export library paths with BoringSSL
export CPPFLAGS="-I$PCAP_DIR -I$PCRE_DIR/src -I$BORINGSSL_DIR/include"
export LDFLAGS="-L$PCAP_DIR -L$PCRE_DIR/.libs -L$BORINGSSL_DIR/lib"

echo "=== Building Nmap for Android (aarch64) with BoringSSL ==="
echo "CC: $CC"
echo "CXX: $CXX"
echo "AR: $AR"
echo "RANLIB: $RANLIB"
echo "CPPFLAGS: $CPPFLAGS"
echo "LDFLAGS: $LDFLAGS"
echo ""

# Clean previous build
make distclean 2>/dev/null || true

# Configure with bundled libraries and BoringSSL
./configure \
    --host=aarch64-linux-android \
    --with-libpcap=included \
    --with-libpcre=included \
    --with-openssl=$BORINGSSL_DIR \
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

echo ""
echo "=== Configuration complete ==="
echo "Now run: make"
