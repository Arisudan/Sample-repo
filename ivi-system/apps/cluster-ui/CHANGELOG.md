# Changelog - ASTER Cluster UI

## [Refactor 2.0] - 2025-12-12
- **Pixel-Perfect UI**: Complete overhaul of `SpeedGauge` and `RpmGauge` to match the neon high-tech reference.
- **Backend Adapter**: Enhanced `ClusterAdapter` to support Weather, Time, and Navigation properties.
- **Navigation**: Added `NavigationView.qml` with vector map drawing (no external assets required).
- **Functionality**: 
  - Real-time binding for ALL gauge values.
  - Interactive Gear Selector.
  - Interactive Turn Signals.
- **Branding**: "ASTER" logo prominent in top bar.
- **Performance**: Canvas-based rendering optimized for 60 FPS on embedded targets.
