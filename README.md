# ASTER IVI System - Execution Procedure

## 1. Introduction
This document details the step-by-step procedure to build, run, and verify the ASTER In-Vehicle Infotainment (IVI) system on a Linux environment (Ubuntu 22.04 LTS). It covers dependency installation, compilation of services and UI, and execution of the simulation harness.

## 2. System Requirements
- **OS**: Ubuntu 22.04 LTS (Jammy Jellyfish) or newer.
- **RAM**: Minimum 4GB (8GB recommended).
- **Disk Space**: 10GB free.
- **Graphics**: OpenGL 2.1+ compatible GPU (for Qt Quick).

## 3. Installing Dependencies
Install all necessary build tools and libraries.

```bash
sudo apt update
sudo apt upgrade -y

# Build Tools
sudo apt install -y build-essential cmake g++ git

# Qt6 Dependencies
sudo apt install -y qt6-base-dev qt6-declarative-dev qt6-declarative-dev-tools \
    qml6-module-qtquick-controls qml6-module-qtquick-shapes qml6-module-qtquick-effects \
    libgl1-mesa-dev libxkbcommon-dev

# VSOMEIP Dependencies (Service Oriented Middleware)
sudo apt install -y libboost-system-dev libboost-thread-dev libboost-log-dev libboost-filesystem-dev

# Test Harness (Python)
sudo apt install -y python3 python3-pip
```

*Note: If `vsomeip` is not available in your repo, you may need to build it from source or check if the project provides a local version.*

## 4. Cloning the Project
Assuming you have access to the repository:

```bash
git clone https://github.com/your-org/aster-ivi-system.git
cd aster-ivi-system
```

*(If you are using the generated zip from Antigravity, unzip it and `cd ivi-system`)*

## 5. Project Structure Overview
```text
ivi-system/
├── apps/
│   └── cluster-ui/       # The Qt6 Digital Instrument Cluster
├── services/
│   ├── can-service/      # Vehicle Signal Broker
│   ├── pdc-service/      # Park Distance Control
│   └── media-service/    # Multimedia Logic
├── ipc/
│   └── vsomeip-config/   # IPC Routing Configurations
├── scripts/              # Build and Test Scripts
└── procedure.md          # This file
```

## 6. Building the Backend Services
We will build the CAN, PDC, and Media services.

```bash
# 1. CAN Service
mkdir -p services/can-service/build
cd services/can-service/build
cmake ..
make -j$(nproc)
cd ../../..

# 2. PDC Service
mkdir -p services/pdc-service/build
cd services/pdc-service/build
cmake ..
make -j$(nproc)
cd ../../..

# 3. Media Service
mkdir -p services/media-service/build
cd services/media-service/build
cmake ..
make -j$(nproc)
cd ../../..
```

*Expected Output*: `[100%] Built target ...` for each service.

## 7. Building the Cluster UI
Compile the main HMI application.

```bash
mkdir -p apps/cluster-ui/build
cd apps/cluster-ui/build

# Configure (Ensure Qt6 CMake is found)
cmake ..

# Build
make -j$(nproc)

# Return to root
cd ../../..
```

*Expected Output*: An executable binary named `appcluster-ui` is created in `apps/cluster-ui/build`.

## 8. Running the Backend Services
Open a **Terminal 1** to act as the backend host. We must set the VSOMEIP configuration path so services can discover each other.

```bash
# Export IPC Config
export VSOMEIP_CONFIGURATION=$(pwd)/ipc/vsomeip-config/vsomeip.json

# Run CAN Service (Background)
./services/can-service/build/can_service &

# Run PDC Service (Background)
./services/pdc-service/build/pdc_service &

# Check they are running
ps aux | grep _service
```

## 9. Running the Cluster UI
Open a **Terminal 2**. This will launch the graphical dashboard.

```bash
# Export IPC Config (Clients need it too)
export VSOMEIP_CONFIGURATION=$(pwd)/ipc/vsomeip-config/vsomeip.json

# Run UI
# If you are on a desktop environment:
./apps/cluster-ui/build/appcluster-ui

# If you are on an embedded target without X11:
# ./apps/cluster-ui/build/appcluster-ui --platform linuxfb
```

*Verification*: The "ASTER" dashboard should appear with gauges at 0 and the car logo.

## 10. Connecting Frontend ↔ Backend
The system uses `vsomeip` (Scalable Service-Oriented Middleware over IP).
- **Cluster UI** creates a client application.
- **Backend Services** broadcast events (Speed, RPM).

*No manual connection steps are required; auto-discovery happens via the JSON file.*

## 11. Running Navigation + Car Animation
The Cluster UI logic automatically switches views based on the `nav_active` signal.
- **Default State**: Shows 3D Car Model.
- **Nav Active**: Shows Map Overlay.

This state is controlled via the backend/simulation signals.

## 12. Running the Test Harness
Use the Python script to inject simulation data (Vehicle Speed, Gear, Nav State) into the running system.

Open **Terminal 3**:

```bash
# Run the test script
python3 scripts/cluster_ui_test.py
```

*What to observe:*
1.  **RPM/Speed**: Needles sweep from 0 to 115 km/h smoothly.
2.  **Gear**: Indicator changes P -> N -> D.
3.  **Center View**: Changes from Car Model to Navigation Map when "Activating Navigation..." is logged.
4.  **Blinkers**: Indicators flash during the test sequence.

## 13. Debugging & Logs

**If UI doesn't show:**
Check OpenGL support:
```bash
glxinfo | grep "OpenGL version"
```

**If specific services fail:**
Check vsomeip logs (usually printed to stdout or `/tmp/vsomeip.log` if configured).
Ensure `VSOMEIP_CONFIGURATION` env var is set in **every** terminal.

**Missing Assets:**
If map or car images are missing, ensure `apps/cluster-ui/assets/` contains the required .png files and strictly rebuild if `qrc` resource files were modified.

## 14. Rebuild Steps
If you modify QML or C++ code:

```bash
cd apps/cluster-ui/build
make -j$(nproc)
./appcluster-ui
```

**Full Clean Rebuild:**
```bash
rm -rf apps/cluster-ui/build
mkdir -p apps/cluster-ui/build
cd apps/cluster-ui/build
cmake ..
make -j$(nproc)
```

## 15. Clean-Up Commands
To kill all running services:

```bash
pkill can_service
pkill pdc_service
pkill appcluster-ui
```

## 16. Common Issues & Fixes
- **Error**: `qt.qpa.plugin: Could not find the Qt platform plugin "wayland"`
    - **Fix**: Install `qt6-wayland` or run with `./appcluster-ui --platform xcb` (if using X11).
- **Error**: `vsomeip application ... is not initialized`
    - **Fix**: `export VSOMEIP_CONFIGURATION=...` was skipped.
- **Visuals**: Black screen?
    - **Fix**: Check `QSG_RHI_BACKEND` variable. Try `export QSG_RHI_BACKEND=software` for software rendering if GPU is broken.

## 17. Final Verification Checklist
- [ ] Backend services (CAN, PDC) start without crash.
- [ ] Cluster UI launches with "ASTER" logo visible.
- [ ] Python test script connects successfully.
- [ ] Speedometer needle updates smoothly (60 FPS).
- [ ] Center display toggles between Car and Map.
- [ ] Warning icons respond to signals.
- [ ] No "Echo" or placeholder text visible.

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
📦 Verification Suite
A new test harness script is available: 
ivi-system/scripts/cluster_ui_test.py
.

How to verify:

Compile & Run:
bash
cd ivi-system/apps/cluster-ui
mkdir build && cd build
qt-cmake .. && make
./appcluster-ui
Inject Test Data: Open a new terminal and run:
bash
python3 ../../../scripts/cluster_ui_test.py
Observation: You will see the needles sweep smoothly from 0-120 km/h, the gear shift from P to D, and the center display switch to Navigation mode automatically.
