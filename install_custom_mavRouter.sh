#!/bin/bash
# Algan-Developer: Build Script for existing MAVLink Router Fork
# Added: Auto-venv creation and system-safe dependency installation

set -e # Exit immediately if a command exits with a non-zero status

VENV_DIR=".venv"

echo "--- Installing Build Dependencies ---"
sudo apt update
sudo apt install -y pkg-config gcc g++ systemd ninja-build python3-venv

# 1. Create venv if it doesn't exist
if [ ! -d "$VENV_DIR" ]; then
    echo "Creating virtual environment in $VENV_DIR..."
    python3 -m venv "$VENV_DIR"
fi

# 2. Use the venv's pip to install meson (Avoids PEP 668 error)
echo "Installing/Updating Meson in virtual environment..."
$VENV_DIR/bin/pip install --upgrade pip
$VENV_DIR/bin/pip install meson
$VENV_DIR/bin/pip install pymavlink lxml
$VENV_DIR/bin/pip install opencv-python

echo "--- Updating Internal MAVLink Submodule ---"
git submodule update --init

echo "--- Configuring Build Directory ---"
rm -rf build

cd modules/Algan-Mavlink
bash ./generate_packets.sh
cd ../..
# 3. Call meson from the venv specifically
$VENV_DIR/bin/meson setup build . \
    --buildtype=release \
    -Dsystemdsystemunitdir=/usr/lib/systemd/system

echo "--- Compiling ---"
ninja -C build

echo "--- Installing to System ---"
sudo ninja -C build install

echo "--- Final Verification ---"
if command -v mavlink-routerd &> /dev/null; then
    echo "Success! mavlink-routerd is installed."
    mavlink-routerd --version
else
    echo "Installation failed. Check build logs above."
fi