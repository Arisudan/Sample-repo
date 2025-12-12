#!/bin/bash
echo "Building IVI System Modules..."

# Create build directories
mkdir -p build/can-service
mkdir -p build/pdc-service
mkdir -p build/media-service
mkdir -p build/cluster-ui

# Build CAN Service
echo "--- Building CAN Service ---"
cd build/can-service
cmake ../../services/can-service
make -j4
cd ../..

# Build PDC Service
echo "--- Building PDC Service ---"
cd build/pdc-service
cmake ../../services/pdc-service
make -j4
cd ../..

# Build Media Service
echo "--- Building Media Service ---"
cd build/media-service
cmake ../../services/media-service
make -j4
cd ../..

# Build Cluster UI
echo "--- Building Cluster UI ---"
cd build/cluster-ui
qt-cmake ../../apps/cluster-ui
make -j4
cd ../..

echo "Build Complete. Run services with VSOMEIP_CONFIGURATION=../../ipc/vsomeip-config/vsomeip.json"
