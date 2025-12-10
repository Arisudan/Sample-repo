#!/usr/bin/env python3
import can
import time
import math

def main():
    print("Starting CAN Simulator on vcan0...")
    try:
        bus = can.interface.Bus(channel='vcan0', bustype='socketcan')
    except OSError:
        print("Could not connect to vcan0. Make sure to run: sudo modprobe vcan && sudo ip link add dev vcan0 type vcan && sudo ip link set up vcan0")
        return

    t = 0
    while True:
        # Simulate Speed sine wave 0-200
        speed = int(100 + 100 * math.sin(t * 0.1))
        # RPM 800 - 8000
        rpm = int(4000 + 3000 * math.sin(t * 0.2))
        # Gear 1-6
        gear = int((speed / 40)) + 1
        if gear > 6: gear = 6
        if speed == 0: gear = 0 # P/N

        # Encode: ID 0x100
        # Byte 0-1: Speed
        # Byte 2-3: RPM
        # Byte 4: Gear
        data = [
            (speed >> 8) & 0xFF, speed & 0xFF,
            (rpm >> 8) & 0xFF, rpm & 0xFF,
            gear & 0xFF,
            0, 0, 0
        ]
        
        msg = can.Message(arbitration_id=0x100, data=data, is_extended_id=False)
        bus.send(msg)
        
        print(f"Sent: Speed={speed} RPM={rpm} Gear={gear}")
        
        time.sleep(0.1)
        t += 0.5

if __name__ == "__main__":
    main()
