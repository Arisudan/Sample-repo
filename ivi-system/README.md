# Automotive IVI System

A production-grade In-Vehicle Infotainment system built for Raspberry Pi 4.

## Features
- **Cluster UI**: High-performance Qt 6 Dashboard with CAN integration.
- **Navigation**: Mapbox/OSM support.
- **Media**: Integrated media player.
- **PDC**: Park Distance Control with ultrasonic sensros and audio warnings.
- **Connectivity**: CAN bus (SocketCAN) and vsomeip IPC.

## Structure
- `apps/`: Qt 6 QML Applications.
- `services/`: C++ vsomeip services (CAN, PDC, Media).
- `ipc/`: vsomeip configuration.
- `yocto/`: Yocto integration (meta-ivi-system).
- `scripts/`: Build and deploy utilities.

## Getting Started

### Prerequisites
- Linux Host (Ubuntu 20.04+)
- Yocto Project (Kirkstone)
- Qt 6.5+

### Build
Run the unified build script:
```bash
./scripts/build.sh
```

### Running on Desktop (Simulation)
1. Setup Virtual CAN:
   ```bash
   sudo modprobe vcan
   sudo ip link add dev vcan0 type vcan
   sudo ip link set up vcan0
   ```
2. Run CAN Simulator:
   ```bash
   python3 scripts/run_can_simulator.py
   ```
3. Run Services & App (env var for mock config):
   ```bash
   export VSOMEIP_CONFIGURATION=ipc/vsomeip-config/vsomeip.json
   ./build/can-service/can_service &
   ./build/cluster-ui/appcluster-ui
   ```

## Yocto Build
1. Add `meta-ivi-system` to your `bblayers.conf`.
2. Add `ivi-image` to `local.conf` or run `bitbake ivi-image`.

## License
MIT
