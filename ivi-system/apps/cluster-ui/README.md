# ASTER Cluster UI

Professional Automotive Cluster UI using Qt 6.

## Structure
- `ClusterMain.qml`: Root entry.
- `components/*.qml`: Atomic UI widgets.
- `main.cpp`: C++ Backend Adapter + VSOMEIP Bridge.

## How to Build
```bash
mkdir build && cd build
qt-cmake ..
make -j4
```

## How to Run
```bash
./appcluster-ui
```
*Ensure VSOMEIP environment variables are set if running with real/mocked IPC.*

## How to Test
A built-in UDP listener allows property injection without full backend.

1. Run the app:
   ```bash
   ./appcluster-ui
   ```
2. Run the harness:
   ```bash
   python3 ../../../scripts/cluster_ui_test.py
   ```
   
Observe the speed sweep and gear changes.
