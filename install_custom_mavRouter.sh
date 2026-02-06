#!/bin/bash
# Algan-Developer: Build Script for existing MAVLink Router Fork

set -e # Exit immediately if a command exits with a non-zero status

echo "--- Installing Build Dependencies ---"
# Install essential toolchain components for WSL/Ubuntu
sudo apt update
sudo apt install -y pkg-config gcc g++ systemd python3-pip ninja-build

# mavlink-router requires meson >= 0.55; pip ensures we have the latest
sudo apt install -y meson

echo "--- Updating Internal MAVLink Submodule ---"
# This ensures your fork has the C-headers required for compilation
git submodule update --init

echo "--- Configuring Build Directory ---"
# Meson requires a separate build directory; we clean it if it already exists
rm -rf build
meson setup build . \
    --buildtype=release \
    -Dsystemdsystemunitdir=/usr/lib/systemd/system

echo "--- Compiling ---"
# Using Ninja to compile the project
ninja -C build

echo "--- Installing to System ---"
# Installs the binary to /usr/local/bin by default
sudo ninja -C build install

echo "--- Final Verification ---"
if command -v mavlink-routerd &> /dev/null; then
    echo "Success! mavlink-routerd is installed."
    mavlink-routerd --version
else
    echo "Installation failed. Check build logs above."
fi