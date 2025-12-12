# Changelog - Cluster UI

## [Refactor] - 2025-12-12
- **Hardened C++ Adapter**: `main.cpp` now implements a robust `ClusterAdapter` class with full signal/slot coverage for vehicle properties.
- **Async IPC**: Logic moved to non-blocking thread for VSOMEIP subscription.
- **Test Harness**: Added UDP JSON listener on port 12345 for easy dev/test injection (`scripts/cluster_ui_test.py`).
- **Visual Overhaul**: 
  - New `ClusterMain.qml` structure.
  - Pixel-perfect `SpeedGauge` and `RpmGauge` using Vector Canvas (no images).
  - "STAR" Branding added.
  - "Echo" leaf removed.
- **Interactivity**: 
  - Gear selector is now click-interactive.
  - Arrows are click-interactive.
- **Components**: Separated `TopBar`, `NavigationView`, `CarIllustration` for modularity.
