# Nmap for Android (Fork)

This is a fork of [Nmap](https://nmap.org/), cross-compiled and modified to run on Android devices (AArch64, Android API 24).

---

## About

Nmap (“Network Mapper”) is a powerful open-source tool for network discovery and security auditing. This fork adapts Nmap to Android using the official Android NDK toolchain.

---

## Modifications

- Cross-compiled with Android NDK r29 for ARM64 (aarch64).  
- Fixed compatibility issues in `libdnet` for Android.  
- Disabled OpenSSL and LibSSH2 support due to build environment constraints.  
- Minor Android-specific tweaks to make it run smoothly on Android devices.

---

## Build Instructions

### Prerequisites

- Linux host system  
- Android NDK r29 (or compatible version) installed  
- `make`, `gcc`, `clang`, `autoconf`, `automake`, `libtool` installed  
- `pkg-config` installed  
- `python3` (optional, for some scripts)

### Steps

```bash
# Clone the repo
git clone https://github.com/aeticusdev/nmap-android.git
cd nmap-android

# Set your NDK path (adjust if needed)
export ANDROID_NDK_HOME=$HOME/Android/Sdk/ndk/29.0.13599879

# Export cross-compile tools for aarch64 Android 24
export PATH=$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64/bin:$PATH
export CC=aarch64-linux-android24-clang
export CXX=aarch64-linux-android24-clang++
export AR=aarch64-linux-android24-ar
export LD=aarch64-linux-android24-ld
export RANLIB=aarch64-linux-android24-ranlib
export STRIP=aarch64-linux-android24-strip

# Configure build for Android with minimal features (no OpenSSL, no LibSSH2)
./configure --host=aarch64-linux-android --without-ssl --without-libssh2 --disable-zenmap --disable-nmap-update

# Build
make -j$(nproc)

# After build, nmap binary will be at ./nmap
```

---

## Usage

Push the `nmap` binary to your Android device and run it directly:

```bash
adb push nmap /data/local/tmp/
adb shell
cd /data/local/tmp
chmod +x nmap
./nmap -v
```

---

## License

This project is based on Nmap, licensed under the **Nmap Public Source License (NPSL)**.

You **must keep all original copyright notices and license info intact**.

See the official Nmap legal page for details:  
https://nmap.org/book/man-legal.html

---

## Disclaimer

Use at your own risk. No warranties or guarantees.
