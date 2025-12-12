#!/bin/bash

# ASTER - WSL Launch Helper
# This script installs dependencies, builds, and runs the ASTER Cluster UI in WSL.

set -e

echo "[ASTER] Checking Environment..."

# 1. Install Dependencies (Ubuntu/Debian)
if ! command -v qmake6 &> /dev/null; then
    echo "[ASTER] Qt6 not found. Installing dependencies (requires sudo)..."
    sudo apt-get update
    sudo apt-get install -y build-essential cmake qt6-base-dev qt6-declarative-dev qt6-declarative-dev-tools qt6-wayland qml6-module-qtquick-controls qml6-module-qtquick-shapes qml6-module-qtquick-effects libgl1-mesa-dev
else
    echo "[ASTER] Qt6 found."
fi

# 2. Check for Display
if [ -z "$DISPLAY" ] && [ -z "$WAYLAND_DISPLAY" ]; then
    echo "[WARNING] No DISPLAY variable set."
    echo "If using WSL2, ensure you have WSLg (Windows 11) or an XServer (VcXsrv) running."
    echo "Exporting generic DISPLAY=:0 just in case..."
    export DISPLAY=:0
fi

# 3. Build
echo "[ASTER] Building Cluster UI..."
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="$PROJECT_DIR/apps/cluster-ui/build_wsl"

mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

# Ensure we use Qt6 CMake
cmake "$PROJECT_DIR/apps/cluster-ui" -DCMAKE_PREFIX_PATH=/usr/lib/x86_64-linux-gnu/cmake/Qt6
make -j$(nproc)

# 4. Run
echo "[ASTER] Starting Cluster UI..."
echo "---------------------------------------------------"
echo "If the window does not appear, check your XServer settings."
echo "---------------------------------------------------"

# Run in background so we can run the test harness too if desired, 
# but for now let's run it foreground to see logs.
./appcluster-ui
