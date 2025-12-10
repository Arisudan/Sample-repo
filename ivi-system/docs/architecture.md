# IVI System Architecture

## Overview
This project implements a complete In-Vehicle Infotainment (IVI) system for Raspberry Pi 4. It uses a Service-Oriented Architecture (SOA) based on **vsomeip** (Scalable Service-Oriented Middleware over IP).

## Modules

### 1. Head Unit (Qt 6)
- **Cluster UI**: Displays Speed, RPM, Gear using data from CAN Service.
- **Navigation**: Mapbox integration.
- **Media**: Playback control.
- **Settings**: System format.

### 2. Services (C++ / vsomeip)
- **CAN Service (ID 0x1234)**:
  - Reads CAN frames from `vcan0` (SocketCAN).
  - Publishes: Speed (0x8001), RPM (0x8002), Gear (0x8003).
- **PDC Service (ID 0x5678)**:
  - Reads Ultrasonic sensors (mocked or via sysfs).
  - Publishes: Distance (0x8101).
  - Audio: Generates system beep warnings.
- **Media Service (ID 0x9ABC)**:
  - Backend logic for playback.
  - Publishes: Metadata, Status.

### 3. Messaging (UDP/TCP)
- Configured via `vsomeip.json`.
- Multicast Service Discovery.

## Hardware Setup
- **Raspberry Pi 4**
- **CAN Hat** (e.g., Waveshare RS485 CAN HAT) or virtual CAN.
- **Ultrasonic Sensor (HC-SR04)** connected to GPIO.
- **Touch Display** (HDMI/DSI).

## Build Instructions
See `build_instructions.md`.
